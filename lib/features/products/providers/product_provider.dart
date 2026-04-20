import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/product_model.dart';
import '../../../core/routing/router.dart';

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final session = await ref.watch(supabaseSessionProvider.future);
  if (session == null) return [];

  final response = await Supabase.instance.client
      .from('products')
      .select()
      .eq('merchant_id', session.user.id)
      .order('name', ascending: true);

  return (response as List).map((data) => ProductModel.fromJson(data)).toList();
});

class ProductNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addProduct({
    required String name,
    required String unit,
    required double priceUsd,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      await Supabase.instance.client.from('products').insert({
        'merchant_id': userId,
        'name': name,
        'unit': unit,
        'default_price_usd': priceUsd,
      });

      ref.invalidate(productsProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final productActionProvider = NotifierProvider<ProductNotifier, AsyncValue<void>>(ProductNotifier.new);
