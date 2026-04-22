import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import './providers/customer_provider.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  void _showAddCustomerModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final creditCtrl = TextEditingController();
    final depositCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: D.card(isDark: isDark),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(S.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: S.lg), decoration: BoxDecoration(color: C.bdr(isDark), borderRadius: BorderRadius.circular(2)))),
              Text('Add Customer', style: T.sectionHeader),
              SizedBox(height: S.lg),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline, color: C.sub(isDark)))),
              SizedBox(height: S.md),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined, color: C.sub(isDark)))),
              SizedBox(height: S.md),
              Row(children: [
                Expanded(child: TextField(controller: creditCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Starting Credit', prefixText: '\$ '))),
                SizedBox(width: S.md),
                Expanded(child: TextField(controller: depositCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Starting Deposit', prefixText: '\$ '))),
              ]),
              SizedBox(height: S.xl),
              ElevatedButton(
                onPressed: () {
                  final credit = double.tryParse(creditCtrl.text) ?? 0.0;
                  final deposit = double.tryParse(depositCtrl.text) ?? 0.0;
                  ref.read(customerActionProvider.notifier).addCustomer(name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim(), initialCredit: credit, initialDeposit: deposit);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Customer'),
              ),
              SizedBox(height: S.lg),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncCustomers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: C.bg(isDark),
      body: asyncCustomers.when(
        data: (customers) {
          if (customers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(S.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 80, height: 80, decoration: D.soft(isDark: isDark), child: Icon(Icons.people_outline, size: 40, color: C.sub(isDark))),
                    SizedBox(height: S.lg),
                    Text('No customers yet', style: T.sectionHeader),
                    SizedBox(height: S.xs),
                    Text('Add your first customer to get started', style: T.caption),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(S.lg),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final cust = customers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: S.md),
                padding: const EdgeInsets.all(S.md),
                decoration: D.card(isDark: isDark),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(R.md)),
                      child: Center(child: Text(cust.name.isNotEmpty ? cust.name[0].toUpperCase() : '?', style: T.body.copyWith(fontWeight: FontWeight.w600, color: C.txt(isDark)))),
                    ),
                    SizedBox(width: S.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cust.name, style: T.body.copyWith(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(cust.phone.isNotEmpty ? cust.phone : 'No phone', style: T.caption),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (cust.depositBalance > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: S.xs),
                            decoration: D.soft(isDark: isDark),
                            child: Text('+\$${cust.depositBalance.toStringAsFixed(0)}', style: T.label.copyWith(fontWeight: FontWeight.w600, color: C.txt(isDark))),
                          ),
                        if (cust.creditBalance > 0)
                          Padding(padding: const EdgeInsets.only(top: S.xs), child: Text('Owes \$${cust.creditBalance.toStringAsFixed(2)}', style: T.caption.copyWith(color: C.txt(isDark)))),
                        if (cust.depositBalance <= 0 && cust.creditBalance <= 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: S.sm, vertical: S.xs),
                            decoration: D.soft(isDark: isDark),
                            child: Text('Settled', style: T.caption),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e', style: T.body.copyWith(color: C.accent))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerModal(context, ref),
        backgroundColor: C.accent,
        child: const Icon(Icons.person_add, color: C.textInverse),
      ),
    );
  }
}