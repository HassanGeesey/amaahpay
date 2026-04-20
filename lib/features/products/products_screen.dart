import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_theme.dart';
import './providers/product_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  void _showAddProductModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'piece');
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Add Product',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'kg, piece...',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  ref.read(productActionProvider.notifier).addProduct(
                        name: nameCtrl.text.trim(),
                        unit: unitCtrl.text.trim(),
                        priceUsd: price,
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('Save Product'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProducts = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: asyncProducts.when(
        data: (products) {
          if (products.isEmpty) {
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
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No products yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add your first product to get started',
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
            itemCount: products.length,
            itemBuilder: (context, index) {
              final prod = products[index];
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.mutedText,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prod.name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            'Unit: ${prod.unit}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mutedText,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${prod.defaultPriceUsd.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductModal(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}