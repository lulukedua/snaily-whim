import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/data/models/order_model.dart';
import 'package:snailywhim/data/repositories/order_repository.dart';
import 'package:snailywhim/data/repositories/product_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;
  final ProductRepository productRepository;

  OrderBloc({required this.repository, required this.productRepository})
    : super(OrderInitial()) {
    developer.log("NEW ORDER BLOC CREATED", name: "OrderBloc");
    on<FetchOrders>((event, emit) async {
      try {
        final oldOrders = state is OrderLoaded && event.page > 1
            ? (state as OrderLoaded).orderList
            : <OrderModel>[];
        final oldImages = state is OrderLoaded && event.page > 1
            ? Map<String, String>.from((state as OrderLoaded).orderImages)
            : <String, String>{};
        if (event.page == 1) {
          emit(OrderLoading());
        }
        final list = await repository.getAllOrders(page: event.page);
        final Map<String, String> orderImages = {};
        for (final order in list) {
          if (order.item != null && order.item!.isNotEmpty) {
            final productId =
                order.item!.first['product_id'] ?? order.item!.first['id'];

            if (productId != null) {
              try {
                final productRaw = await productRepository.getProductRawById(
                  productId,
                );

                if (productRaw['image_url'] != null) {
                  orderImages[order.id] = productRaw['image_url'];
                }
              } catch (_) {}
            }
          }
        }
        emit(
          OrderLoaded(
            [...oldOrders, ...list],
            orderImages: {...oldImages, ...orderImages},
            hasMore: list.length == 10,
          ),
        );
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<FetchMyOrders>((event, emit) async {
      try {
        final oldOrders = state is OrderLoaded && event.page > 1
            ? (state as OrderLoaded).orderList
            : <OrderModel>[];
        final oldImages = state is OrderLoaded && event.page > 1
            ? Map<String, String>.from((state as OrderLoaded).orderImages)
            : <String, String>{};
        if (event.page == 1) {
          emit(OrderLoading());
        }
        final list = await repository.getOrdersByUser(
          userId: event.userId,
          page: event.page,
        );
        final Map<String, String> orderImages = {};
        for (final order in list) {
          if (order.item != null && order.item!.isNotEmpty) {
            final productId =
                order.item!.first['product_id'] ?? order.item!.first['id'];
            if (productId != null) {
              try {
                final productRaw = await productRepository.getProductRawById(
                  productId,
                );

                if (productRaw['image_url'] != null) {
                  orderImages[order.id] = productRaw['image_url'];
                }
              } catch (_) {}
            }
          }
        }
        emit(
          OrderLoaded(
            [...oldOrders, ...list],
            orderImages: {...oldImages, ...orderImages},
            hasMore: list.length == 10,
          ),
        );
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<FetchOrderById>((event, emit) async {
      emit(OrderLoading());

      try {
        final order = await repository.getOrderById(event.id);
        final Map<String, String> itemImages = {};
        if (order.item != null) {
          for (var item in order.item!) {
            final productId = item['product_id'] ?? item['id'];

            if (productId != null && !itemImages.containsKey(productId)) {
              try {
                final productRaw = await productRepository.getProductRawById(
                  productId,
                );
                final imageUrl = productRaw['image_url'];

                if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                  itemImages[productId.toString()] = imageUrl.toString();
                }
              } catch (e) {
                developer.log(
                  'Gagal fetch gambar detail untuk $productId',
                  name: 'OrderBloc',
                );
              }
            }
          }
        }

        emit(OrderDetailLoaded(order, itemImages: itemImages));
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<CreateOrder>((event, emit) async {
      emit(OrderLoading());
      try {
        final result = await repository.createOrder(
          items: event.items,
          totalHarga: event.totalHarga,
          userId: event.userId,
        );
        emit(
          OrderCreatedSuccess(
            orderId: result["order_id"],
            snapToken: result["snap_token"],
          ),
        );
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<UpdateOrderStatus>((event, emit) async {
      emit(OrderLoading());

      try {
        await repository.updateOrderStatus(
          orderId: event.orderId,
          statusOrder: event.statusOrder,
        );

        emit(OrderUpdatedSuccess());
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<UpdatePaymentStatus>((event, emit) async {
      emit(OrderLoading());

      try {
        await repository.updatePaymentStatus(
          orderId: event.orderId,
          paymentStatus: event.paymentStatus,
        );

        emit(OrderUpdatedSuccess());
      } catch (e) {
        developer.log(e.toString(), name: 'OrderBloc');

        emit(OrderError(e.toString()));
      }
    });
    on<DeleteOrder>((event, emit) async {
      emit(OrderLoading());

      try {
        await repository.deleteOrder(event.orderId);

        emit(OrderUpdatedSuccess());
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });
    on<SaveMidtransData>((event, emit) async {
      try {
        await repository.saveMidtransData(
          orderId: event.orderId,
          snapToken: event.snapToken,
          midtransOrderId: event.midtransOrderId,
        );
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<FetchNotificationOrders>((event, emit) async {
      try {
        final currentState = state;
        final oldOrders = currentState is OrderLoaded && event.page > 1
            ? currentState.orderList
            : <OrderModel>[];
        final oldImages = currentState is OrderLoaded && event.page > 1
            ? Map<String, String>.from(currentState.orderImages)
            : <String, String>{};
        if (event.page == 1) {
          emit(OrderLoading());
        }

        final list = await repository.getNotificationOrders(
          userId: event.userId,
          page: event.page,
        );

        final Map<String, String> orderImages = {};

        for (final order in list) {
          if (order.item != null && order.item!.isNotEmpty) {
            final productId =
                order.item!.first['product_id'] ?? order.item!.first['id'];

            if (productId != null) {
              try {
                final productRaw = await productRepository.getProductRawById(
                  productId,
                );

                if (productRaw['image_url'] != null) {
                  orderImages[order.id] = productRaw['image_url'];
                }
              } catch (_) {}
            }
          }
        }
        developer.log(
          "Loaded ${list.length} data, hasMore = ${list.length == 10}",
        );
        developer.log("OLD = ${oldOrders.length}", name: "OrderBloc");

        developer.log("NEW = ${list.length}", name: "OrderBloc");

        developer.log(
          "TOTAL = ${oldOrders.length + list.length}",
          name: "OrderBloc",
        );

        emit(
          OrderLoaded(
            [...oldOrders, ...list],
            orderImages: {...oldImages, ...orderImages},
            hasMore: list.length == 10,
          ),
        );
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });
  }
}
