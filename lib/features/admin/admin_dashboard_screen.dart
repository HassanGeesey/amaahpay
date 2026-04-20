import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_theme.dart';
import '../../data/models/profile_model.dart';
import './providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _showBillingModal(BuildContext context, WidgetRef ref, ProfileModel profile) {
    final priceCtrl = TextEditingController(text: '15.00');
    String selectedCycle = 'monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 24, right: 24, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4)
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Manage Subscription',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  profile.name,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCycle,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly (30 Days)')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly (365 Days)')),
                    ],
                    onChanged: (val) => setState(() => selectedCycle = val ?? 'monthly'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Agreed Price (USD)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () async {
                    final price = double.tryParse(priceCtrl.text) ?? 15.0;
                    await ref.read(adminActionProvider.notifier).assignBilling(
                      merchantId: profile.id,
                      cycle: selectedCycle,
                      price: price,
                    );
                    if (context.mounted) {
                       Navigator.pop(ctx);
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                           content: Text('Billing plan applied successfully!'),
                           backgroundColor: AppColors.success,
                         ),
                       );
                    }
                  },
                  child: const Text('Apply Plan & Activate'),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAddMerchantModal(BuildContext context, WidgetRef ref) {
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
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4)
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Create Merchant',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildInput('Full Name', nameCtrl, Icons.person),
              const SizedBox(height: AppSpacing.md),
              _buildInput('Email', emailCtrl, Icons.email, type: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.md),
              _buildInput('Phone Number', phoneCtrl, Icons.phone, type: TextInputType.phone),
              const SizedBox(height: AppSpacing.md),
              _buildInput('Shop Name', shopCtrl, Icons.store),
              const SizedBox(height: AppSpacing.md),
              _buildInput('Password', passCtrl, Icons.lock, isPassword: true),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () async {
                  final success = await ref.read(adminActionProvider.notifier).createMerchant(
                    email: emailCtrl.text,
                    password: passCtrl.text,
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                    shopName: shopCtrl.text,
                  );
                  
                  if (!context.mounted) return;
                  
                  if (success) {
                     Navigator.pop(ctx);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text('Merchant Account Created!'),
                         backgroundColor: AppColors.success,
                       ),
                     );
                  } else {
                     final error = ref.read(adminActionProvider).error;
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Failed: $error'), 
                         backgroundColor: AppColors.error,
                       ),
                     );
                  }
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, {TextInputType type = TextInputType.text, bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfiles = ref.watch(adminProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text('Merchants'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.mutedText),
            onPressed: () async => await Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: asyncProfiles.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      size: 40,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No merchants yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add your first merchant to get started',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _buildMerchantCard(context, ref, profile);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMerchantModal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Merchant'),
      ),
    );
  }

  Widget _buildMerchantCard(BuildContext context, WidgetRef ref, ProfileModel profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _showBillingModal(context, ref, profile),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: profile.isActive 
                      ? AppColors.primaryOrange.withAlpha(26) 
                      : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: profile.isActive ? AppColors.primaryOrange : AppColors.mutedText,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.shopName ?? profile.name,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600,
                          color: profile.isActive ? AppColors.darkText : AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.phone ?? profile.name,
                        style: TextStyle(fontSize: 13, color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: profile.isActive 
                      ? AppColors.success.withAlpha(26) 
                      : AppColors.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    profile.isActive ? 'Active' : 'Disabled',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: profile.isActive ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Switch.adaptive(
                  value: profile.isActive,
                  activeColor: AppColors.primaryOrange,
                  onChanged: (val) {
                    ref.read(adminActionProvider.notifier).toggleActivation(profile.id, profile.isActive);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}