import 'package:equatable/equatable.dart';
import 'package:snailywhim/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orderList;
  final Map<String, String> orderImages;

  final bool hasMore;
  final bool isLoadingMore;

  OrderLoaded(
    this.orderList, {
    this.orderImages = const {},
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        orderList,
        orderImages,
        hasMore,
        isLoadingMore,
      ];
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  final Map<String, String> itemImages;

  OrderDetailLoaded(this.order, {this.itemImages = const {}});

  @override
  List<Object?> get props => [order];
}

class OrderCreatedSuccess extends OrderState {
  final String orderId;
  final String snapToken;
  OrderCreatedSuccess({required this.orderId, required this.snapToken});
  @override
  List<Object?> get props => [orderId, snapToken];
}

class OrderUpdatedSuccess extends OrderState {}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
