import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routing/router.dart';

final merchantProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final session = await ref.watch(supabaseSessionProvider.future);
  if (session == null) throw Exception('Not logged in');

  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', session.user.id)
      .single();
  return response as Map<String, dynamic>;
});

class ProfileNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String shopName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      await Supabase.instance.client
          .from('profiles')
          .update({
            'name': name,
            'phone': phone,
            'shop_name': shopName,
          })
          .eq('id', userId);

      ref.invalidate(merchantProfileProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileActionProvider =
    NotifierProvider<ProfileNotifier, AsyncValue<void>>(ProfileNotifier.new);
