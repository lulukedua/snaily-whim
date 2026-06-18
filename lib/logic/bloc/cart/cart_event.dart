import 'package:equatable/equatable.dart';
import 'package:snailywhim/data/models/cart_model.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItemModel item;

  AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String productId;

  RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class IncreaseQty extends CartEvent {
  final String productId;

  IncreaseQty(this.productId);

  @override
  List<Object?> get props => [productId];
}

class DecreaseQty extends CartEvent {
  final String productId;

  DecreaseQty(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCart extends CartEvent {}
class ToggleCartItem extends CartEvent {
  final String productId;

  ToggleCartItem(this.productId);
}

class RemoveCheckedOutItems extends CartEvent {
  final List<String> productIds;

  RemoveCheckedOutItems(this.productIds);
}