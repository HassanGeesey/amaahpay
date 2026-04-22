import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_theme.dart';
import '../../data/models/profile_model.dart';
import './providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _showBillingModal(BuildContext context, WidgetRef ref, ProfileModel profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceCtrl = TextEditingController(text: '15.00');
    String selectedCycle = 'monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: D.card(isDark: isDark),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: C.bdr(isDark), borderRadius: BorderRadius.circular(4)))),
                Text('Manage Subscription', style: T.sectionHeader),
                Text(profile.name, style: T.label),
                const SizedBox(height: 16),
                Container(
                  decoration: D.soft(isDark: isDark),
                  child: DropdownButtonFormField<String>(
                    value: selectedCycle,
                    decoration: InputDecoration(labelText: 'Billing Cycle', border: InputBorder.none, prefixIcon: Icon(Icons.calendar_today_outlined, color: C.sub(isDark))),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly (30 Days)')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly (365 Days)')),
                    ],
                    onChanged: (val) => setState(() => selectedCycle = val ?? 'monthly'),
                  ),
                ),
                SizedBox(height: S.md),
                TextField(controller: priceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Agreed Price (USD)', prefixIcon: Icon(Icons.attach_money, color: C.sub(isDark)))),
                SizedBox(height: S.xl),
                ElevatedButton(
                  onPressed: () async {
                    final price = double.tryParse(priceCtrl.text) ?? 15.0;
                    await ref.read(adminActionProvider.notifier).assignBilling(merchantId: profile.id, cycle: selectedCycle, price: price);
                    if (context.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Billing plan applied successfully!'), backgroundColor: AppColors.neutral900)); }
                  },
                  child: const Text('Apply Plan & Activate'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMerchantModal(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final shopCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: D.card(isDark: isDark),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: S.xl), decoration: BoxDecoration(color: C.bdr(isDark), borderRadius: BorderRadius.circular(4)))),
              Text('Create Merchant', style: T.sectionHeader),
              SizedBox(height: S.lg),
              _buildInput('Full Name', nameCtrl, Icons.person, isDark),
              SizedBox(height: S.md),
              _buildInput('Email', emailCtrl, Icons.email, isDark, type: TextInputType.emailAddress),
              SizedBox(height: S.md),
              _buildInput('Phone Number', phoneCtrl, Icons.phone, isDark, type: TextInputType.phone),
              SizedBox(height: S.md),
              _buildInput('Shop Name', shopCtrl, Icons.store, isDark),
              SizedBox(height: S.md),
              _buildInput('Password', passCtrl, Icons.lock, isDark, isPassword: true),
              SizedBox(height: S.xl),
              ElevatedButton(
                onPressed: () async {
                  final success = await ref.read(adminActionProvider.notifier).createMerchant(email: emailCtrl.text, password: passCtrl.text, name: nameCtrl.text, phone: phoneCtrl.text, shopName: shopCtrl.text);
                  if (!context.mounted) return;
                  if (success) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merchant Account Created!'), backgroundColor: AppColors.neutral900)); }
                  else { final error = ref.read(adminActionProvider).error; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $error'), backgroundColor: C.accent)); }
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, bool isDark, {TextInputType type = TextInputType.text, bool isPassword = false}) {
    return TextField(controller: ctrl, keyboardType: type, obscureText: isPassword, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20, color: C.sub(isDark))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncProfiles = ref.watch(adminProfilesProvider);

    return Scaffold(
      backgroundColor: C.bg(isDark),
      appBar: AppBar(
        title: Text('Merchants', style: T.sectionHeader),
        actions: [IconButton(icon: Icon(Icons.logout, color: C.sub(isDark)), onPressed: () async => await Supabase.instance.client.auth.signOut())],
      ),
      body: asyncProfiles.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(S.xxl),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 80, height: 80, decoration: D.soft(isDark: isDark), child: Icon(Icons.storefront_outlined, size: 40, color: C.sub(isDark))),
                  SizedBox(height: S.lg),
                  Text('No merchants yet', style: T.sectionHeader),
                  SizedBox(height: S.xs),
                  Text('Add your first merchant to get started', style: T.caption),
                ]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(S.lg),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _buildMerchantCard(context, ref, profile, isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e', style: T.body.copyWith(color: C.accent))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMerchantModal(context, ref),
        backgroundColor: C.accent,
        icon: const Icon(Icons.add, color: C.textInverse),
        label: Text('Add Merchant', style: T.body.copyWith(color: C.textInverse)),
      ),
    );
  }

  Widget _buildMerchantCard(BuildContext context, WidgetRef ref, ProfileModel profile, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: S.md),
      decoration: D.card(isDark: isDark),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(R.xxl),
          onTap: () => _showBillingModal(context, ref, profile),
          child: Padding(
            padding: const EdgeInsets.all(S.md),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: profile.isActive ? (isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6)) : D.soft(isDark: isDark).color, borderRadius: BorderRadius.circular(R.md)),
                  child: Icon(Icons.storefront_rounded, color: profile.isActive ? C.txt(isDark) : C.sub(isDark)),
                ),
                SizedBox(height: S.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(profile.shopName ?? profile.name, style: T.body.copyWith(fontWeight: FontWeight.w600, color: profile.isActive ? C.txt(isDark) : C.sub(isDark))),
                    const SizedBox(height: 2),
                    Text(profile.phone ?? profile.name, style: T.caption),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: S.xs),
                  decoration: D.soft(isDark: isDark),
                  child: Text(profile.isActive ? 'Active' : 'Disabled', style: T.label.copyWith(fontWeight: FontWeight.w600, color: C.txt(isDark))),
                ),
                SizedBox(height: S.sm),
                Switch.adaptive(
                  value: profile.isActive,
                  activeColor: C.accent,
                  onChanged: (val) { ref.read(adminActionProvider.notifier).toggleActivation(profile.id, profile.isActive); },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}