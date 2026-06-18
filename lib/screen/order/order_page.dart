import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/core/theme/colors.dart';
import 'package:snailywhim/core/widgets/app_snackbar.dart';
import 'package:snailywhim/core/widgets/infinite_scroll.dart';
import 'package:snailywhim/core/widgets/order_card.dart';
import 'package:snailywhim/data/models/cart_model.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'package:snailywhim/logic/bloc/cart/cart_bloc.dart';
import 'package:snailywhim/logic/bloc/cart/cart_event.dart';
import 'package:snailywhim/logic/bloc/order/order_bloc.dart';
import 'package:snailywhim/logic/bloc/order/order_event.dart';
import 'package:snailywhim/logic/bloc/order/order_state.dart';
import 'package:snailywhim/screen/order/order_detail_page.dart';

class OrderPage extends StatefulWidget {
  final String userId;
  final bool isAdmin;
  final String initialFilter;

  const OrderPage({
    super.key,
    required this.userId,
    this.isAdmin = false,
    this.initialFilter = 'All',
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _page = 1;
  bool _loadingMore = false;
  late String selectedFilter = 'All';
  final List<String> filters = ['All', 'Waiting', 'Process', 'Selesai'];
  late final OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    // _fetchInitialData();
    _orderBloc =
        OrderBloc(
          repository: OrderRepository(),
          productRepository: ProductRepository(),
        )..add(
          widget.isAdmin
              ? FetchOrders(page: 1)
              : FetchMyOrders(userId: widget.userId, page: 1),
        );
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    _page++;
    _orderBloc.add(
      widget.isAdmin
          ? FetchOrders(page: _page)
          : FetchMyOrders(userId: widget.userId, page: _page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.bgBtmColor,
          elevation: 0,
          title: Text(widget.isAdmin ? "Daftar Pesanan Masuk" : "Pesanan Saya"),
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.bgColor,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? AppColors.primColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? AppColors.primTextColor
                              : AppColors.secondaryTextColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderLoaded) {
                    developer.log(
                      "UI BUILD = ${state.orderList.length}",
                      name: "OrderPage",
                    );
                    setState(() {
                      _loadingMore = false;
                    });
                  }
                  if (state is OrderUpdatedSuccess) {
                    context.read<OrderBloc>().add(
                      widget.isAdmin
                          ? FetchOrders(page: 1)
                          : FetchMyOrders(userId: widget.userId, page: 1),
                    );
                    AppSnackbar.show(
                      context,
                      title: 'Berhasil',
                      message: 'Status pesanan berhasil diperbarui!',
                      type: SnackType.success,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading && _page == 1) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primColor,
                      ),
                    );
                  }

                  if (state is OrderLoaded) {
                    final filteredOrders = selectedFilter == 'All'
                        ? state.orderList
                        : state.orderList
                              .where(
                                (order) =>
                                    order.status_order.toLowerCase() ==
                                    selectedFilter.toLowerCase(),
                              )
                              .toList();

                    if (filteredOrders.isEmpty) {
                      return InfiniteListView(
                        onLoadMore: _loadMore,
                        hasMore: state.hasMore,
                        isLoading: _loadingMore,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Belum ada pesanan ($selectedFilter)",
                                      style: const TextStyle(
                                        color: AppColors.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return InfiniteListView(
                      onLoadMore: _loadMore,
                      hasMore: state.hasMore,
                      isLoading: _loadingMore,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount:
                            filteredOrders.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (index >= filteredOrders.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primColor,
                                ),
                              ),
                            );
                          }

                          final order = filteredOrders[index];

                          return OrderCard(
                            order: order,
                            imageUrl: state.orderImages[order.id],
                            isAdmin: widget.isAdmin,
                            onStatusChanged: (newStatus) {
                              context.read<OrderBloc>().add(
                                UpdateOrderStatus(
                                  orderId: order.id,
                                  statusOrder: newStatus,
                                ),
                              );
                            },
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailPage(
                                    orderId: order.id,
                                    isAdmin: widget.isAdmin,
                                  ),
                                ),
                              );

                              if (context.mounted) {
                                context.read<OrderBloc>().add(
                                  widget.isAdmin
                                      ? FetchOrders(page: 1)
                                      : FetchMyOrders(
                                          userId: widget.userId,
                                          page: 1,
                                        ),
                                );
                              }
                            },
                            onBeliLagi: () {
                              if (order.item != null &&
                                  order.item!.isNotEmpty) {
                                final firstItem = order.item!.first;

                                context.read<CartBloc>().add(
                                  AddToCart(
                                    CartItemModel(
                                      productId:
                                          firstItem['product_id'] ??
                                          firstItem['id'],
                                      namaProduct: firstItem['nama_product'],
                                      harga: firstItem['harga'] is String
                                          ? int.tryParse(firstItem['harga']) ??
                                                0
                                          : firstItem['harga'],
                                      qty: 1,
                                    ),
                                  ),
                                );

                                AppSnackbar.show(
                                  context,
                                  title: 'Berhasil',
                                  message:
                                      "${firstItem['nama_product']} berhasil ditambah ke keranjang!",
                                  type: SnackType.success,
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
