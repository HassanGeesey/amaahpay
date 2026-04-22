import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_theme.dart';
import '../../shared/widgets/dual_currency_text.dart';
import '../../data/models/sale_model.dart';
import './providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(reportsProvider);

    return RefreshIndicator(
      color: C.accent,
      onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(S.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCards(context, state, isDark),
            SizedBox(height: S.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: T.sectionHeader),
                if (!state.isLoading && state.error == null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.xs),
                    decoration: D.soft(isDark: isDark),
                    child: Text('${state.sales.length}', style: T.label.copyWith(fontWeight: FontWeight.w600, color: C.txt(isDark))),
                  ),
              ],
            ),
            SizedBox(height: S.md),
            _buildFilters(context, ref, state, isDark),
            SizedBox(height: S.lg),
            _buildTransactionList(context, state, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReportsState state, bool isDark) {
    final todaysTotal = state.todaysSalesTotal;
    final sosTotal = todaysTotal * 2700;
    final pendingCredit = state.totalPendingCredit;
    final sosPending = pendingCredit * 2700;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(S.lg),
            decoration: D.darkCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.point_of_sale_rounded, color: C.textInverse, size: 16), SizedBox(height: S.xs), Text("Today's Revenue", style: T.label.copyWith(color: C.textInverse))]),
                SizedBox(height: S.sm),
                if (state.isLoading)
                  SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: C.textInverse))
                else if (state.error != null)
                  Text('—', style: T.sectionHeader.copyWith(color: C.textInverse))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${todaysTotal.toStringAsFixed(2)}', style: T.sectionHeader),
                      Text('${sosTotal.toStringAsFixed(0)} SOS', style: T.caption.copyWith(color: C.textInverse.withAlpha(179))),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: S.md),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(S.lg),
            decoration: D.card(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.account_balance_wallet_outlined, color: C.sub(isDark), size: 16), SizedBox(height: S.xs), Text('Pending Credit', style: T.label)]),
                SizedBox(height: S.sm),
                if (state.isLoading)
                  SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: C.sub(isDark)))
                else if (state.error != null)
                  Text('—', style: T.sectionHeader)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${pendingCredit.toStringAsFixed(2)}', style: T.sectionHeader.copyWith(color: C.txt(isDark))),
                      Text('${sosPending.toStringAsFixed(0)} SOS', style: T.caption),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, ReportsState state, bool isDark) {
    final filters = ReportsDateFilter.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isActive = state.dateFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: S.sm),
            child: GestureDetector(
              onTap: () => ref.read(reportsProvider.notifier).setDateFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
                decoration: BoxDecoration(
                  color: isActive ? C.accent : C.card(isDark),
                  border: Border.all(color: isActive ? C.accent : C.bdr(isDark)),
                  borderRadius: BorderRadius.circular(R.full),
                ),
                child: Text(filter.label, style: T.label.copyWith(color: isActive ? C.textInverse : C.sub(isDark), fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, ReportsState state, bool isDark) {
    if (state.isLoading) return Center(child: Padding(padding: const EdgeInsets.all(S.xxxl), child: CircularProgressIndicator(color: C.accent)));
    if (state.error != null) return _buildError(context, state.error.toString(), isDark);
    if (state.sales.isEmpty) return _buildEmptyState(context, isDark);
    return Column(children: state.sales.map((sale) => _SaleTile(sale: sale, isDark: isDark)).toList());
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(S.xxxl),
      decoration: D.card(isDark: isDark),
      child: Column(children: [
        Icon(Icons.receipt_long_outlined, size: 48, color: C.sub(isDark)),
        SizedBox(height: S.md),
        Text('No transactions yet', style: T.sectionHeader),
        SizedBox(height: S.xs),
        Text('Sales will appear here once you process them from the POS.', textAlign: TextAlign.center, style: T.caption),
      ]),
    );
  }

  Widget _buildError(BuildContext context, String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(S.xl),
      decoration: D.card(isDark: isDark),
      child: Column(children: [
        const Icon(Icons.error_outline, color: C.accent, size: 32),
        SizedBox(height: S.sm),
        Text('Failed to load transactions', style: T.sectionHeader),
        SizedBox(height: S.xs),
        Text(error, style: T.caption.copyWith(color: C.accent)),
      ]),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final SaleModel sale;
  final bool isDark;

  const _SaleTile({required this.sale, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, h:mm a').format(sale.createdAt.toLocal());
    final hasCreditAdded = sale.creditAddedUsd > 0;
    final sosTotal = sale.totalUsd * 2700;

    return Container(
      margin: const EdgeInsets.only(bottom: S.md),
      padding: const EdgeInsets.all(S.lg),
      decoration: D.card(isDark: isDark),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, decoration: D.soft(isDark: isDark), child: Icon(Icons.receipt_long_outlined, color: C.sub(isDark), size: 18)),
              SizedBox(height: S.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sale.customerName, style: T.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(timeStr, style: T.caption),
                ]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${sale.totalUsd.toStringAsFixed(2)}', style: T.body.copyWith(fontWeight: FontWeight.w700)),
                  Text('${sosTotal.toStringAsFixed(0)} SOS', style: T.caption),
                ],
              ),
            ],
          ),
          SizedBox(height: S.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
            decoration: D.soft(isDark: isDark),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PaymentChip(icon: Icons.payments_outlined, label: 'Cash', value: '\$${sale.cashPaidUsd.toStringAsFixed(2)}', color: C.txt(isDark), isDark: isDark),
                if (sale.depositUsedUsd > 0) _PaymentChip(icon: Icons.savings_outlined, label: 'Deposit', value: '\$${sale.depositUsedUsd.toStringAsFixed(2)}', color: C.sub(isDark), isDark: isDark),
                if (hasCreditAdded) _PaymentChip(icon: Icons.account_balance_wallet_outlined, label: 'Credit', value: '+\$${sale.creditAddedUsd.toStringAsFixed(2)}', color: C.txt(isDark), isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _PaymentChip({required this.icon, required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: T.caption),
        Text(value, style: T.label.copyWith(fontWeight: FontWeight.w600, color: color)),
      ]),
    ]);
  }
}