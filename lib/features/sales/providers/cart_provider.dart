import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import '../../customers/providers/customer_provider.dart';

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

  Future<void> processSale() async {
    final customer = state.selectedCustomer;
    if (customer == null || state.items.isEmpty) return;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final total = state.grandTotal;
    final cashPaid = state.cashPaidUsd;
    final remainingAfterCash = total - cashPaid;

    double usedDeposit = 0.0;
    double newCredit = 0.0;

    if (remainingAfterCash > 0) {
      if (customer.depositBalance >= remainingAfterCash) {
        usedDeposit = remainingAfterCash;
      } else {
        usedDeposit = customer.depositBalance;
        newCredit = remainingAfterCash - customer.depositBalance;
      }
    }

    final creditBalanceAfter = customer.creditBalance + newCredit;
    final depositBalanceAfter = customer.depositBalance - usedDeposit;

    // 1. Insert into Sales
    final saleData = await supabase.from('sales').insert({
      'merchant_id': userId,
      'customer_id': customer.id,
      'total_usd': total,
      'cash_paid_usd': cashPaid,
      'deposit_used_usd': usedDeposit,
      'credit_added_usd': newCredit,
      'notes': 'POS Sale',
    }).select().single();

    final saleId = saleData['id'];

    // 2. Insert Sale Items
    final saleItems = state.items.map((item) => {
      'sale_id': saleId,
      'product_id': item.product.id,
      'product_name': item.product.name,
      'unit': item.product.unit,
      'quantity': item.quantity,
      'price_usd': item.overridePriceUsd,
    }).toList();

    await supabase.from('sale_items').insert(saleItems);

    // 3. Insert Ledger Entry
    await supabase.from('ledger').insert({
      'merchant_id': userId,
      'customer_id': customer.id,
      'sale_id': saleId,
      'type': 'sale',
      'amount_usd': total,
      'credit_balance_after': creditBalanceAfter,
      'deposit_balance_after': depositBalanceAfter,
      'note': 'POS Sale at checkout',
    });

    // 4. Update Customer Balance
    await supabase.from('customers').update({
      'credit_balance': creditBalanceAfter,
      'deposit_balance': depositBalanceAfter,
    }).eq('id', customer.id);

    // Invalidate the customers to pull fresh balances immediately
    ref.invalidate(customersProvider);

    clearCart();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
