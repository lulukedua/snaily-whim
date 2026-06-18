import 'package:equatable/equatable.dart';
import 'package:snailywhim/data/models/cart_model.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final Set<String> selectedIds;

  CartLoaded(this.items, {Set<String>? selectedIds})
    : selectedIds = selectedIds ?? {}{
      print("SELECTED IDS = $selectedIds");
    }
  int get total => items.fold(0, (sum, item) => sum + item.subtotal);
  @override
  List<Object?> get props => [items, selectedIds];
}

class CartError extends CartState {
  final String message;

  CartError(this.message);

  @override
  List<Object?> get props => [message];
}
