import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import '../customers/customers_screen.dart';
import '../products/products_screen.dart';
import '../sales/checkout_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/providers/settings_provider.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends ConsumerState<MerchantDashboardScreen> {
  int _currentIndex = 0;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return const CheckoutScreen();
      case 1: return const CustomersScreen();
      case 2: return const ProductsScreen();
      case 3: return const ReportsScreen();
      case 4: default: return const SettingsScreen();
    }
  }

  String _title(String? shopName) {
    switch (_currentIndex) {
      case 0: return shopName ?? 'My Shop';
      case 1: return 'Customers';
      case 2: return 'Products';
      case 3: return 'Reports';
      case 4: return 'Settings';
      default: return shopName ?? 'My Shop';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(merchantProfileProvider);
    final shopName = profileAsync.whenOrNull(data: (p) => p['shop_name'] as String?);

    return Scaffold(
      backgroundColor: C.bg(isDark),
      appBar: AppBar(
        title: Text(_title(shopName), style: T.sectionHeader),
        actions: [
          IconButton(icon: Icon(Icons.logout, color: C.sub(isDark)), onPressed: () async => await Supabase.instance.client.auth.signOut()),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: C.card(isDark),
        border: Border(top: BorderSide(color: C.bdr(isDark), width: 0.5)),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.point_of_sale_rounded, label: 'POS', isSelected: _currentIndex == 0, isDark: isDark, onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(icon: Icons.people_outline, label: 'Customers', isSelected: _currentIndex == 1, isDark: isDark, onTap: () => setState(() => _currentIndex = 1)),
              _NavItem(icon: Icons.inventory_2_outlined, label: 'Products', isSelected: _currentIndex == 2, isDark: isDark, onTap: () => setState(() => _currentIndex = 2)),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports', isSelected: _currentIndex == 3, isDark: isDark, onTap: () => setState(() => _currentIndex = 3)),
              _NavItem(icon: Icons.settings_outlined, label: 'Settings', isSelected: _currentIndex == 4, isDark: isDark, onTap: () => setState(() => _currentIndex = 4)),
            ],
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
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selectedColor = C.accentColor(isDark);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)) : Colors.transparent,
          borderRadius: BorderRadius.circular(R.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? selectedColor : C.sub(isDark), size: 24),
            const SizedBox(height: 4),
            Text(label, style: T.caption.copyWith(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? selectedColor : C.sub(isDark))),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(merchantProfileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(S.lg, S.lg, S.lg, S.lg + MediaQuery.of(context).padding.bottom + 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('ACCOUNT', isDark),
          SizedBox(height: S.md),
          _buildSettingsCard(context, [
            _SettingsTile(icon: Icons.person_outline, title: 'Profile', isDark: isDark, onTap: () => _showProfileDialog(context, ref, profileAsync)),
            _SettingsDivider(isDark: isDark),
            _SettingsTile(icon: Icons.store_outlined, title: 'Shop Settings', isDark: isDark, onTap: () => _showShopSettingsDialog(context, ref, profileAsync)),
          ], isDark),
          SizedBox(height: S.xl),
          _buildSectionTitle('PREFERENCES', isDark),
          SizedBox(height: S.md),
          _buildSettingsCard(context, [
            _SettingsTile(icon: Icons.dark_mode_outlined, title: 'Dark Mode', isDark: isDark, trailing: _buildThemeToggle(ref, themeMode), onTap: () {}),
            _SettingsDivider(isDark: isDark),
            _SettingsTile(icon: Icons.language_outlined, title: 'Language', isDark: isDark, trailing: Text('English', style: T.label), onTap: () {}),
            _SettingsDivider(isDark: isDark),
            _SettingsTile(icon: Icons.attach_money_rounded, title: 'Currency', isDark: isDark, trailing: Text('USD / SOS', style: T.label), onTap: () => _showCurrencyDialog(context, ref)),
          ], isDark),
          SizedBox(height: S.xl),
          _buildSectionTitle('SUPPORT', isDark),
          SizedBox(height: S.md),
          _buildSettingsCard(context, [
            _SettingsTile(icon: Icons.help_outline_rounded, title: 'Help Center', isDark: isDark, onTap: () {}),
            _SettingsDivider(isDark: isDark),
            _SettingsTile(icon: Icons.info_outline_rounded, title: 'About', isDark: isDark, onTap: () => _showAboutDialog(context)),
          ], isDark),
          SizedBox(height: S.xl),
          _buildSectionTitle('DANGER ZONE', isDark),
          SizedBox(height: S.md),
          _buildSettingsCard(context, [
            _SettingsTile(icon: Icons.logout_rounded, title: 'Sign Out', titleColor: C.txt(isDark), isDark: isDark, onTap: () => _confirmSignOut(context)),
          ], isDark),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(WidgetRef ref, ThemeMode themeMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : themeMode == ThemeMode.light ? Icons.light_mode_rounded : Icons.brightness_auto_rounded, size: 18, color: C.textSecondary),
        const SizedBox(width: 4),
        Text(themeMode == ThemeMode.dark ? 'On' : themeMode == ThemeMode.light ? 'Off' : 'Auto', style: T.caption),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: themeMode == ThemeMode.dark,
          onChanged: (value) => ref.read(themeModeProvider.notifier).setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title, style: T.upperLabel);
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children, bool isDark) {
    return Container(decoration: D.card(isDark: isDark), child: Column(children: children));
  }

  void _showProfileDialog(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> profileAsync) {
    profileAsync.whenData((profile) {
      final nameCtrl = TextEditingController(text: profile['name'] ?? '');
      final phoneCtrl = TextEditingController(text: profile['phone'] ?? '');
      final isDark = Theme.of(context).brightness == Brightness.dark;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
          title: Text('Edit Profile', style: T.sectionHeader),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder())),
            SizedBox(height: S.md),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(profileActionProvider.notifier).updateProfile(name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(), shopName: profile['shop_name'] ?? '');
                  ref.refresh(merchantProfileProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: C.accent));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    });
  }

  void _showShopSettingsDialog(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> profileAsync) {
    profileAsync.whenData((profile) {
      final shopCtrl = TextEditingController(text: profile['shop_name'] ?? '');
      final isDark = Theme.of(context).brightness == Brightness.dark;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
          title: Text('Shop Settings', style: T.sectionHeader),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: shopCtrl, decoration: const InputDecoration(labelText: 'Shop Name', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(profileActionProvider.notifier).updateProfile(name: profile['name'] ?? '', phone: profile['phone'] ?? '', shopName: shopCtrl.text.trim());
                  ref.refresh(merchantProfileProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: C.accent));
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    });
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    final rateCtrl = TextEditingController(text: '2700');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        title: Text('Currency Settings', style: T.sectionHeader),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Set the exchange rate for converting USD to Somali Shilling (SOS).', style: T.body),
          SizedBox(height: S.lg),
          TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'USD → SOS Rate', border: OutlineInputBorder(), prefixText: '1 USD = ', suffixText: 'SOS'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exchange rate saved'), backgroundColor: C.accent)); }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        title: Row(children: [
          Container(width: 40, height: 40, decoration: D.darkCard, child: const Icon(Icons.point_of_sale_rounded, color: C.textInverse, size: 22)),
          SizedBox(height: S.md),
          Text('AmaahPay', style: T.sectionHeader),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Version 1.0.0', style: T.body),
          SizedBox(height: S.md),
          Text('AmaahPay is a financial management app for merchants, supporting offline-first sales, customer credit tracking, and dual-currency display.', style: T.caption),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        title: Text('Sign Out', style: T.sectionHeader),
        content: Text('Are you sure you want to sign out?', style: T.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: C.accent),
            onPressed: () async { Navigator.pop(ctx); await Supabase.instance.client.auth.signOut(); },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  final bool isDark;
  const _SettingsDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: C.bdr(isDark), margin: const EdgeInsets.only(left: 64));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback onTap;
  final bool isDark;

  const _SettingsTile({required this.icon, required this.title, this.trailing, this.titleColor, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = titleColor ?? C.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.xl),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(R.md)),
              child: Icon(icon, color: accent, size: 20),
            ),
            SizedBox(width: S.md),
            Expanded(child: Text(title, style: T.body.copyWith(color: titleColor ?? C.txt(isDark)))),
            if (trailing != null) trailing!,
            if (trailing == null) Icon(Icons.chevron_right, color: C.sub(isDark)),
          ],
        ),
      ),
    );
  }
}