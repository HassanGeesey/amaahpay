import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';
import '../../../core/routing/router.dart';
import '../../../core/constants/env.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final adminProfilesProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final session = await ref.watch(supabaseSessionProvider.future);
  if (session == null) return [];

  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'merchant')
      .order('created_at', ascending: false);

  return (response as List).map((data) => ProfileModel.fromJson(data)).toList();
});

class AdminNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> toggleActivation(String profileId, bool currentStatus) async {
    state = const AsyncValue.loading();
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'is_active': !currentStatus})
          .eq('id', profileId);

      ref.invalidate(adminProfilesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> assignBilling({
    required String merchantId,
    required String cycle,
    required double price,
  }) async {
    state = const AsyncValue.loading();
    try {
      final adminId = Supabase.instance.client.auth.currentUser?.id;
      if (adminId == null) throw Exception('Admin not logged in');

      // Calculate expiry
      final now = DateTime.now();
      final expiry = cycle == 'yearly' ? now.add(const Duration(days: 365)) : now.add(const Duration(days: 30));

      await Supabase.instance.client.from('billing_plans').insert({
        'merchant_id': merchantId,
        'admin_id': adminId,
        'cycle': cycle,
        'price_usd': price,
        'activated_at': now.toIso8601String(),
        'expires_at': expiry.toIso8601String(),
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createMerchant({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String shopName,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Use direct HTTP POST to completely bypass Gotrue Storage assertions and avoid logging out!
      final url = Uri.parse('${Env.supabaseUrl}/auth/v1/signup');
      final response = await http.post(
        url,
        headers: {
          'apikey': Env.supabaseAnonKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'data': {
            'name': name.trim(),
            'phone': phone.trim(),
            'shop_name': shopName.trim(),
            'role': 'merchant',
          }
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode >= 400) {
        throw Exception(jsonResponse['msg'] ?? jsonResponse['message'] ?? 'Signup failed');
      }
      
      // Extract the new user's UUID from the raw GoTrue JSON response
      final newUserId = jsonResponse['user']?['id'] ?? jsonResponse['id'];

      if (newUserId != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': newUserId,
          'name': name.trim(),
          'phone': phone.trim(),
          'shop_name': shopName.trim(),
          'role': 'merchant',
          'is_active': false,
        });
      }

      ref.invalidate(adminProfilesProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final adminActionProvider = NotifierProvider<AdminNotifier, AsyncValue<void>>(AdminNotifier.new);
