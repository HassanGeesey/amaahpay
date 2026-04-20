import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';

class CartItem {
  final ProductModel product;
  final double quantity;
  final double overridePriceUsd;

  CartItem({
    required this.product,
    required this.quantity,
    required this.overridePriceUsd,
  });

  double get total => quantity * overridePriceUsd;
}

class CartState {
  final CustomerModel? selectedCustomer;
  final List<CartItem> items;
  final double cashPaidUsd;

  CartState({
    this.selectedCustomer,
    this.items = const [],
    this.cashPaidUsd = 0.0,
  });

  double get grandTotal => items.fold(0, (sum, item) => sum + item.total);

  CartState copyWith({
    CustomerModel? selectedCustomer,
    List<CartItem>? items,
    double? cashPaidUsd,
  }) {
    return CartState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      items: items ?? this.items,
      cashPaidUsd: cashPaidUsd ?? this.cashPaidUsd,
    );
  }
  
  // Custom nullifier
  CartState clearCustomer() {
    return CartState(items: items, cashPaidUsd: cashPaidUsd, selectedCustomer: null);
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  void selectCustomer(CustomerModel? customer) {
    if (customer == null) {
      state = state.clearCustomer();
    } else {
      state = state.copyWith(selectedCustomer: customer);
    }
  }

  void addItem(ProductModel product, double qty, double price) {
    final newItems = List<CartItem>.from(state.items)
      ..add(CartItem(product: product, quantity: qty, overridePriceUsd: price));
    state = state.copyWith(items: newItems);
  }

  void removeItem(int index) {
    final newItems = List<CartItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: newItems);
  }

  void updateItem(int index, double qty, double price) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<CartItem>.from(state.items);
    newItems[index] = CartItem(
      product: newItems[index].product,
      quantity: qty,
      overridePriceUsd: price,
    );
    state = state.copyWith(items: newItems);
  }

  void setCashPaid(double amount) {
    state = state.copyWith(cashPaidUsd: amount);
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
