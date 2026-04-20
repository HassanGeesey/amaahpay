import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import './providers/cart_provider.dart';
import '../customers/providers/customer_provider.dart';
import '../products/providers/product_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final asyncCustomers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Column(
        children: [
          _buildCustomerSelector(context, ref, cartState, asyncCustomers),
          Expanded(child: _buildCartItems(context, ref, cartState)),
          _buildCheckoutBar(context, ref, cartState),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () => _showAddCartItemModal(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(BuildContext context, WidgetRef ref, CartState cartState, AsyncValue<List<dynamic>> asyncCustomers) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primaryOrange, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: asyncCustomers.maybeWhen(
              data: (customers) => DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text('Select customer...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText)),
                value: cartState.selectedCustomer?.id,
                items: customers.map((c) => DropdownMenuItem<String>(value: c.id as String, child: Text(c.name))).toList(),
                onChanged: (id) {
                  final c = customers.firstWhere((element) => element.id == id);
                  ref.read(cartProvider.notifier).selectCustomer(c);
                },
              ),
              orElse: () => const Text('Loading...'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, WidgetRef ref, CartState cartState) {
    if (cartState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 36, color: AppColors.mutedText),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No items in cart', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Tap + to add products', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: cartState.items.length,
      itemBuilder: (context, idx) {
        final item = cartState.items[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: AppColors.mutedText, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: Theme.of(context).textTheme.bodyLarge),
                    Text('${item.quantity} ${item.product.unit} @ \$${item.overridePriceUsd}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText)),
                  ],
                ),
              ),
              Text('\$${item.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () => ref.read(cartProvider.notifier).removeItem(idx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, WidgetRef ref, CartState cartState) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              Text('\$${cartState.grandTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Cash received',
                      border: InputBorder.none,
                      prefixText: '\$ ',
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    ),
                    onChanged: (val) => ref.read(cartProvider.notifier).setCashPaid(double.tryParse(val) ?? 0.0),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => _showCheckoutBreakdown(context, ref),
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCartItemModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Text('Add Product', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (c, r, _) {
                  final prods = r.watch(productsProvider).value ?? [];
                  if (prods.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.mutedText),
                            const SizedBox(height: AppSpacing.md),
                            Text('No products yet', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText)),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Add products from Products tab', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText)),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: prods.length,
                    itemBuilder: (context, idx) {
                      final p = prods[idx];
                      return _ProductTile(name: p.name, unit: p.unit, price: p.defaultPriceUsd, onTap: () {
                        ref.read(cartProvider.notifier).addItem(p, 1, p.defaultPriceUsd);
                        Navigator.pop(context);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutBreakdown(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider);
    if (cart.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer first'), backgroundColor: AppColors.error));
      return;
    }
    final total = cart.grandTotal;
    final availableDeposit = cart.selectedCustomer!.depositBalance;
    final cashPaid = cart.cashPaidUsd;
    final remainingAfterCash = total - cashPaid;
    double usedDeposit = 0.0;
    double finalCredit = 0.0;
    if (remainingAfterCash > 0) {
      if (availableDeposit >= remainingAfterCash) {
        usedDeposit = remainingAfterCash;
      } else {
        usedDeposit = availableDeposit;
        finalCredit = remainingAfterCash - availableDeposit;
      }
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Confirm Sale', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              _SummaryRow(label: 'Total Cost', value: '\$${total.toStringAsFixed(2)}'),
              _SummaryRow(label: 'Cash Paid', value: '\$${cashPaid.toStringAsFixed(2)}'),
              _SummaryRow(label: 'Deposit Used', value: '\$${usedDeposit.toStringAsFixed(2)}', valueColor: AppColors.success),
              Container(height: 1, color: AppColors.divider, margin: const EdgeInsets.symmetric(vertical: AppSpacing.md)),
              _SummaryRow(label: 'New Credit', value: '\$${finalCredit.toStringAsFixed(2)}', valueColor: finalCredit > 0 ? AppColors.error : AppColors.darkText, isBold: true),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).clearCart();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale processed!'), backgroundColor: AppColors.success));
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name;
  final String unit;
  final double price;
  final VoidCallback onTap;
  const _ProductTile({required this.name, required this.unit, required this.price, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.mutedText, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.bodyLarge),
                  Text(unit, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText)),
                ],
              ),
            ),
            Text('\$${price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;
  const _SummaryRow({required this.label, required this.value, this.valueColor, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText)),
          Text(value, style: isBold ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: valueColor ?? AppColors.darkText) : Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor ?? AppColors.darkText)),
        ],
      ),
    );
  }
}