import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_theme.dart';
import '../customers/customers_screen.dart';
import '../products/products_screen.dart';
import '../sales/checkout_screen.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends ConsumerState<MerchantDashboardScreen> {
  int _currentIndex = 0;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const CheckoutScreen();
      case 1:
        return const CustomersScreen();
      case 2:
        return const ProductsScreen();
      case 3:
      default:
        return const SettingsScreen();
    }
  }

  String get _title {
    switch (_currentIndex) {
      case 0:
        return 'My Shop';
      case 1:
        return 'Customers';
      case 2:
        return 'Products';
      case 3:
        return 'Settings';
      default:
        return 'My Shop';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.mutedText),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.point_of_sale_rounded,
                  label: 'POS',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.people_outline,
                  label: 'Customers',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryOrange : AppColors.mutedText,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.0,
                color: isSelected ? AppColors.primaryOrange : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + MediaQuery.of(context).padding.bottom + 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'ACCOUNT'),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsCard([
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {},
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.store_outlined,
              title: 'Shop Settings',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle(context, 'PREFERENCES'),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsCard([
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              trailing: Text(
                'English',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              onTap: () {},
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.attach_money_rounded,
              title: 'Currency',
              trailing: Text(
                'USD',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle(context, 'SUPPORT'),
          const SizedBox(height: AppSpacing.md),
          _buildSettingsCard([
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help Center',
              onTap: () {},
            ),
            _SettingsDivider(),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'About',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.mutedText,
            letterSpacing: 1.2,
          ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.only(left: 64));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(
                Icons.chevron_right,
                color: AppColors.mutedText,
              ),
          ],
        ),
      ),
    );
  }
}