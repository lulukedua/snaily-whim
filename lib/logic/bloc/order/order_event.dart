import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchOrders extends OrderEvent {
  final int page;

  FetchOrders({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class FetchOrderById extends OrderEvent {
  final String id;

  FetchOrderById(this.id);

  @override
  List<Object?> get props => [id];
}

class FetchMyOrders extends OrderEvent {
  final String userId;
  final int page;

  FetchMyOrders({required this.userId, this.page = 1});

  @override
  List<Object?> get props => [userId, page];
}

class CreateOrder extends OrderEvent {
  final List<Map<String, dynamic>> items;
  final int totalHarga;
  final String userId;

  CreateOrder({
    required this.items,
    required this.totalHarga,
    required this.userId,
  });

  @override
  List<Object?> get props => [items, totalHarga, userId];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final String statusOrder;

  UpdateOrderStatus({required this.orderId, required this.statusOrder});

  @override
  List<Object?> get props => [orderId, statusOrder];
}

class UpdatePaymentStatus extends OrderEvent {
  final String orderId;
  final String paymentStatus;

  UpdatePaymentStatus({required this.orderId, required this.paymentStatus});

  @override
  List<Object?> get props => [orderId, paymentStatus];
}

class DeleteOrder extends OrderEvent {
  final String orderId;

  DeleteOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class SaveMidtransData extends OrderEvent {
  final String orderId;
  final String snapToken;
  final String midtransOrderId;

  SaveMidtransData({
    required this.orderId,
    required this.snapToken,
    required this.midtransOrderId,
  });

  @override
  List<Object?> get props => [orderId, snapToken, midtransOrderId];
}

class FetchNotificationOrders extends OrderEvent {
  final String userId;
  final int page;

  FetchNotificationOrders({required this.userId, this.page = 1});
}
