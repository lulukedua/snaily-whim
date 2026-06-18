import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snailywhim/data/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc({required this.repository}) : super(CartInitial()) {
    on<LoadCart>((event, emit) async {
      emit(CartLoading());
      final items = await repository.getCart();
      emit(CartLoaded(items));
    });

    on<AddToCart>((event, emit) async {
      print("ADD TO CART : ${event.item.namaProduct}");
      await repository.addToCart(event.item);
      add(LoadCart());
    });

    on<RemoveFromCart>((event, emit) async {
      await repository.removeItem(event.productId);
      add(LoadCart());
    });

    on<IncreaseQty>((event, emit) async {
      final items = await repository.getCart();
      final item = items.firstWhere((e) => e.productId == event.productId);
      await repository.updateQty(productId: item.productId, qty: item.qty + 1);
      add(LoadCart());
    });

    on<DecreaseQty>((event, emit) async {
      final items = await repository.getCart();
      final item = items.firstWhere((e) => e.productId == event.productId);
      if (item.qty <= 1) {
        await repository.removeItem(item.productId);
      } else {
        await repository.updateQty(
          productId: item.productId,
          qty: item.qty - 1,
        );
      }
      add(LoadCart());
    });

    on<ClearCart>((event, emit) async {
      await repository.clearCart();
      emit(CartLoaded([]));
    });

    on<ToggleCartItem>((event, emit) {
      if (state is! CartLoaded) return;
      final current = state as CartLoaded;
      final selected = Set<String>.from(current.selectedIds);
      if (selected.contains(event.productId)) {
        selected.remove(event.productId);
      } else {
        selected.add(event.productId);
      }
      emit(CartLoaded(current.items, selectedIds: selected));
    });

    on<RemoveCheckedOutItems>((event, emit) async {
      for (final id in event.productIds) {
        await repository.removeItem(id);
      }
      add(LoadCart());
    });
  }
}
