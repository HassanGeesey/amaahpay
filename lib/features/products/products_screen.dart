import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import '../../shared/widgets/dual_currency_text.dart';
import './providers/product_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  void _showAddProductModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'piece');
    final priceCtrl = TextEditingController();
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
              Text('Add Product', style: T.sectionHeader),
              SizedBox(height: S.lg),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Product Name', prefixIcon: Icon(Icons.inventory_2_outlined, color: C.sub(isDark)))),
              SizedBox(height: S.md),
              Row(children: [
                Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit', hintText: 'kg, piece...'))),
                SizedBox(height: S.md),
                Expanded(child: TextField(controller: priceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price', prefixText: '\$ '))),
              ]),
              SizedBox(height: S.xl),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  ref.read(productActionProvider.notifier).addProduct(name: nameCtrl.text.trim(), unit: unitCtrl.text.trim(), priceUsd: price);
                  Navigator.pop(ctx);
                },
                child: const Text('Save Product'),
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
    final asyncProducts = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: C.bg(isDark),
      body: asyncProducts.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(S.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 80, height: 80, decoration: D.soft(isDark: isDark), child: Icon(Icons.inventory_2_outlined, size: 40, color: C.sub(isDark))),
                    SizedBox(height: S.lg),
                    Text('No products yet', style: T.sectionHeader),
                    SizedBox(height: S.xs),
                    Text('Add your first product to get started', style: T.caption),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(S.lg),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final prod = products[index];
              final sosPrice = prod.defaultPriceUsd * 2700;
              return Container(
                margin: const EdgeInsets.only(bottom: S.md),
                padding: const EdgeInsets.all(S.md),
                decoration: D.card(isDark: isDark),
                child: Row(
                  children: [
                    Container(width: 48, height: 48, decoration: D.soft(isDark: isDark), child: Icon(Icons.inventory_2_outlined, color: C.sub(isDark), size: 24)),
                    SizedBox(height: S.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod.name, style: T.body.copyWith(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('Unit: ${prod.unit}', style: T.caption),
                        ],
                      ),
                    ),
                    DualCurrencyText(usd: prod.defaultPriceUsd, sos: sosPrice, showBoth: true),
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
        onPressed: () => _showAddProductModal(context, ref),
        backgroundColor: C.accent,
        child: const Icon(Icons.add, color: C.textInverse),
      ),
    );
  }
}