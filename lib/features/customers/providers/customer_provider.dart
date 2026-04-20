import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/customer_model.dart';
import '../../../core/routing/router.dart';

final customersProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final session = await ref.watch(supabaseSessionProvider.future);
  if (session == null) return [];

  final response = await Supabase.instance.client
      .from('customers')
      .select()
      .eq('merchant_id', session.user.id)
      .order('name', ascending: true);

  return (response as List).map((data) => CustomerModel.fromJson(data)).toList();
});

class CustomerNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addCustomer({
    required String name,
    required String phone,
    required double initialCredit,
    required double initialDeposit,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      await Supabase.instance.client.from('customers').insert({
        'merchant_id': userId,
        'name': name,
        'phone': phone,
        'credit_balance': initialCredit,
        'deposit_balance': initialDeposit,
      });

      // Invalidate to trigger un-cached re-fetch
      ref.invalidate(customersProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final customerActionProvider = NotifierProvider<CustomerNotifier, AsyncValue<void>>(CustomerNotifier.new);
