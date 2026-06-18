import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/infinite_scroll.dart';
import 'package:snailywhim/core/widgets/notification_badge.dart';
import 'package:snailywhim/core/widgets/notification_card.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/logic/bloc/order/order_bloc.dart';
import 'package:snailywhim/logic/bloc/order/order_event.dart';
import 'package:snailywhim/logic/bloc/order/order_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int page = 1;
  bool loadingMore = false;
  late final String userId;
  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBadgeProvider>().markRead();
    });
    userId = Supabase.instance.client.auth.currentUser!.id;
    _orderBloc = OrderBloc(
      repository: OrderRepository(),
      productRepository: ProductRepository(),
    )..add(FetchNotificationOrders(userId: userId, page: 1));
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  Future<void> loadMore() async {
    if (loadingMore) return;
    setState(() => loadingMore = true);
    page++;
    _orderBloc.add(FetchNotificationOrders(userId: userId, page: page));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // create: (_) => OrderBloc(
      //   repository: OrderRepository(),
      //   productRepository: ProductRepository(),
      // )..add(FetchNotificationOrders(userId: userId, page: 1)),
      value: _orderBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primColor,
          title: const Text("Notifikasi"),
        ),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderLoaded) {
              setState(() {
                loadingMore = false;
              });
            }
            if (state is OrderError) {
              setState(() {
                loadingMore = false;
              });
              AppSnackbar.show(
                context,
                title: 'Gagal',
                message: state.message,
                type: SnackType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading && page == 1) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primColor),
              );
            }
            if (state is OrderLoaded) {
              if (state.orderList.isEmpty) {
                return const Center(child: Text("Belum ada notifikasi"));
              }

              return Column(
                children: [
                  Expanded(
                    // ListView harus di-wrap Expanded dalam Column
                    child: InfiniteListView(
                      hasMore: state.hasMore,
                      isLoading: loadingMore,
                      onLoadMore: loadMore,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount:
                            state.orderList.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.orderList.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primColor,
                                ),
                              ),
                            );
                          }
                          return NotificationCard(
                            order: state.orderList[index],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is OrderError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
