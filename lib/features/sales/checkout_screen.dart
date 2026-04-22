import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../shared/widgets/dual_currency_text.dart';
import '../../data/models/product_model.dart';
import './providers/cart_provider.dart';
import '../customers/providers/customer_provider.dart';
import '../products/providers/product_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);
    final asyncCustomers = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: C.bg(isDark),
      body: Column(
        children: [
          _buildCustomerSelector(context, ref, cartState, asyncCustomers, isDark),
          Expanded(child: _buildCartItems(context, ref, cartState, isDark)),
          _buildCheckoutBar(context, ref, cartState, isDark),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: FloatingActionButton(
          onPressed: () => _showAddCartItemModal(context, ref),
          backgroundColor: C.accent,
          child: const Icon(Icons.add, color: C.textInverse),
        ),
      ),
    );
  }

  Widget _buildCustomerSelector(BuildContext context, WidgetRef ref, CartState cartState, AsyncValue<List<dynamic>> asyncCustomers, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(S.lg),
      padding: const EdgeInsets.all(S.lg),
      decoration: D.card(isDark: isDark),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: isDark ? const Color(0xFF333333) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(R.md)), child: Icon(Icons.person_outline, color: C.txt(isDark), size: 20)),
          SizedBox(width: S.md),
          Expanded(
            child: asyncCustomers.maybeWhen(
              data: (customers) => DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text('Select customer...', style: T.body.copyWith(color: C.sub(isDark))),
                value: cartState.selectedCustomer?.id,
                items: customers.map((c) => DropdownMenuItem<String>(value: c.id as String, child: Text(c.name))).toList(),
                onChanged: (id) { final c = customers.firstWhere((e) => e.id == id); ref.read(cartProvider.notifier).selectCustomer(c); },
              ),
              orElse: () => Text('Loading...', style: T.body.copyWith(color: C.sub(isDark))),
            ),
          ),
          IconButton(onPressed: () => _showAddCustomerDialog(context, ref), icon: Icon(Icons.person_add_outlined, color: C.txt(isDark), size: 22), tooltip: 'Add new customer'),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, WidgetRef ref, CartState cartState, bool isDark) {
    if (cartState.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(S.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 80, height: 80, decoration: D.soft(isDark: isDark), child: Icon(Icons.shopping_cart_outlined, size: 36, color: C.sub(isDark))),
              SizedBox(height: S.lg),
              Text('No items in cart', style: T.sectionHeader),
              SizedBox(height: S.xs),
              Text('Tap + to add products', style: T.caption),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: S.lg),
      itemCount: cartState.items.length,
      itemBuilder: (context, idx) {
        final item = cartState.items[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: S.md),
          padding: const EdgeInsets.all(S.md),
          decoration: D.card(isDark: isDark),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: D.soft(isDark: isDark), child: Icon(Icons.inventory_2_outlined, color: C.sub(isDark), size: 20)),
              SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: T.body),
                    Text('${item.quantity} ${item.product.unit} @ \$${item.overridePriceUsd.toStringAsFixed(2)}', style: T.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${item.total.toStringAsFixed(2)}', style: T.body.copyWith(fontWeight: FontWeight.w600)),
                  Text('${(item.total * 2700).toStringAsFixed(0)} SOS', style: T.caption),
                ],
              ),
              SizedBox(width: S.sm),
              IconButton(icon: Icon(Icons.delete_outline, color: C.txt(isDark), size: 20), onPressed: () => ref.read(cartProvider.notifier).removeItem(idx)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, WidgetRef ref, CartState cartState, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(S.lg, S.md, S.lg, S.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: C.card(isDark), border: Border(top: BorderSide(color: C.bdr(isDark)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: T.label),
              Text('\$${cartState.grandTotal.toStringAsFixed(2)}', style: T.sectionHeader),
            ],
          ),
          SizedBox(height: S.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: D.soft(isDark: isDark),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: T.body,
                    decoration: InputDecoration(hintText: 'Cash received', hintStyle: T.body.copyWith(color: C.sub(isDark)), border: InputBorder.none, prefixText: '\$ ', prefixStyle: T.body, contentPadding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md)),
                    onChanged: (val) => ref.read(cartProvider.notifier).setCashPaid(double.tryParse(val) ?? 0.0),
                  ),
                ),
              ),
              SizedBox(width: S.md),
              SizedBox(width: 140, child: ElevatedButton(onPressed: () => _showCheckoutBreakdown(context, ref), child: const Text('Checkout'))),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final depositController = TextEditingController(text: '0');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        title: Text('New Customer', style: T.sectionHeader),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
          SizedBox(height: S.md),
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
          SizedBox(height: S.md),
          TextField(controller: depositController, decoration: const InputDecoration(labelText: 'Initial Deposit (USD)', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              try {
                await ref.read(customerActionProvider.notifier).addCustomer(name: nameController.text.trim(), phone: phoneController.text.trim(), initialCredit: 0, initialDeposit: double.tryParse(depositController.text) ?? 0);
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: C.accent));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCartItemModal(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: D.card(isDark: isDark),
        child: Column(
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: S.md), decoration: BoxDecoration(color: C.bdr(isDark), borderRadius: BorderRadius.circular(2)))),
            Padding(
              padding: const EdgeInsets.all(S.lg),
              child: Row(
                children: [
                  Text('Add Product', style: T.sectionHeader),
                  const Spacer(),
                  TextButton.icon(onPressed: () { Navigator.pop(context); _showAddProductDialog(context, ref); }, icon: const Icon(Icons.add, size: 18), label: const Text('New')),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: C.sub(isDark))),
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
                        padding: const EdgeInsets.all(S.xxl),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: C.sub(isDark)),
                          SizedBox(height: S.md),
                          Text('No products yet', style: T.body.copyWith(color: C.sub(isDark))),
                          SizedBox(height: S.xs),
                          Text('Tap "New" to add your first product', style: T.caption),
                        ]),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: S.lg),
                    itemCount: prods.length,
                    itemBuilder: (context, idx) {
                      final p = prods[idx];
                      return _ProductTile(name: p.name, unit: p.unit, price: p.defaultPriceUsd, isDark: isDark, onTap: () { Navigator.pop(context); _showQuantityPriceDialog(context, ref, p); });
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

  void _showQuantityPriceDialog(BuildContext context, WidgetRef ref, ProductModel p) {
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: p.defaultPriceUsd.toStringAsFixed(2));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        title: Text(p.name, style: T.sectionHeader),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: TextField(controller: qtyController, decoration: InputDecoration(labelText: 'Quantity (${p.unit})', border: const OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
            SizedBox(width: S.md),
            Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Unit Price (USD)', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true))),
          ]),
          SizedBox(height: S.md),
          Builder(builder: (_) {
            final qty = double.tryParse(qtyController.text) ?? 1;
            final price = double.tryParse(priceController.text) ?? p.defaultPriceUsd;
            return Text('Total: \$${(qty * price).toStringAsFixed(2)}', style: T.sectionHeader.copyWith(color: C.accent));
          }),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { final qty = double.tryParse(qtyController.text) ?? 1; final price = double.tryParse(priceController.text) ?? p.defaultPriceUsd; ref.read(cartProvider.notifier).addItem(p, qty, price); Navigator.pop(ctx); }, child: const Text('Add to Cart')),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final unitController = TextEditingController(text: 'piece');
    final priceController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        title: Text('New Product', style: T.sectionHeader),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder())),
          SizedBox(height: S.md),
          TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (e.g. kg, piece, bag)', border: OutlineInputBorder())),
          SizedBox(height: S.md),
          TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Default Price (USD)', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            if (nameController.text.trim().isEmpty) return;
            try {
              await ref.read(productActionProvider.notifier).addProduct(name: nameController.text.trim(), unit: unitController.text.trim(), priceUsd: double.tryParse(priceController.text) ?? 0);
              if (context.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: C.accent));
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _showCheckoutBreakdown(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cart.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer first'), backgroundColor: AppColors.neutral900));
      return;
    }
    final total = cart.grandTotal;
    final sosTotal = total * 2700;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.xxl)),
        child: Padding(
          padding: const EdgeInsets.all(S.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Confirm Sale', style: T.sectionHeader),
              SizedBox(height: S.lg),
              _SummaryRow(label: 'Total Cost', value: '\$${total.toStringAsFixed(2)}', sosValue: '${sosTotal.toStringAsFixed(0)} SOS', isDark: isDark),
              _SummaryRow(label: 'Cash Paid', value: '\$${cashPaid.toStringAsFixed(2)}', isDark: isDark),
              _SummaryRow(label: 'Deposit Used', value: '\$${usedDeposit.toStringAsFixed(2)}', valueColor: C.txt(isDark), isDark: isDark),
              Container(height: 1, color: C.bdr(isDark), margin: const EdgeInsets.symmetric(vertical: S.md)),
              _SummaryRow(label: 'New Credit', value: '\$${finalCredit.toStringAsFixed(2)}', valueColor: finalCredit > 0 ? C.txt(isDark) : C.txt(isDark), isBold: true, isDark: isDark),
              SizedBox(height: S.xl),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                  SizedBox(height: S.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref.read(cartProvider.notifier).processSale();
                          if (context.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale processed successfully!'), backgroundColor: AppColors.neutral900)); }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: C.accent));
                        }
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
  final bool isDark;

  const _ProductTile({required this.name, required this.unit, required this.price, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: D.soft(isDark: isDark), child: Icon(Icons.inventory_2_outlined, color: C.sub(isDark), size: 20)),
            SizedBox(width: S.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: T.body.copyWith(fontWeight: FontWeight.w500)), Text(unit, style: T.caption)])),
            Text('\$${price.toStringAsFixed(2)}', style: T.body.copyWith(fontWeight: FontWeight.w600, color: C.accent)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String? sosValue;
  final Color? valueColor;
  final bool isBold;
  final bool isDark;

  const _SummaryRow({required this.label, required this.value, this.sosValue, this.valueColor, this.isBold = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: S.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: T.body.copyWith(color: C.sub(isDark))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: (isBold ? T.sectionHeader : T.body).copyWith(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: valueColor ?? C.txt(isDark))),
              if (sosValue != null) Text(sosValue!, style: T.caption),
            ],
          ),
        ],
      ),
    );
  }
}