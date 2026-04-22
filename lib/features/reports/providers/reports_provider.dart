import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/sale_model.dart';
import '../../../core/routing/router.dart';

// ─── Date filter enum ────────────────────────────────────────────────────────

enum ReportsDateFilter { today, week, month, allTime }

extension ReportsDateFilterLabel on ReportsDateFilter {
  String get label {
    switch (this) {
      case ReportsDateFilter.today:
        return 'Today';
      case ReportsDateFilter.week:
        return 'This Week';
      case ReportsDateFilter.month:
        return 'This Month';
      case ReportsDateFilter.allTime:
        return 'All Time';
    }
  }

  DateTime? get since {
    final now = DateTime.now();
    switch (this) {
      case ReportsDateFilter.today:
        return DateTime(now.year, now.month, now.day);
      case ReportsDateFilter.week:
        return now.subtract(const Duration(days: 7));
      case ReportsDateFilter.month:
        return DateTime(now.year, now.month, 1);
      case ReportsDateFilter.allTime:
        return null;
    }
  }
}

// ─── State class ─────────────────────────────────────────────────────────────

class ReportsState {
  final ReportsDateFilter dateFilter;
  final List<SaleModel> sales;
  final bool isLoading;
  final Object? error;

  const ReportsState({
    this.dateFilter = ReportsDateFilter.allTime,
    this.sales = const [],
    this.isLoading = true,
    this.error,
  });

  ReportsState copyWith({
    ReportsDateFilter? dateFilter,
    List<SaleModel>? sales,
    bool? isLoading,
    Object? error,
  }) {
    return ReportsState(
      dateFilter: dateFilter ?? this.dateFilter,
      sales: sales ?? this.sales,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Today's revenue: cash paid + deposit used from all sales created today
  double get todaysSalesTotal {
    if (isLoading || error != null) return 0.0;
    final now = DateTime.now();
    return sales
        .where((s) =>
            s.createdAt.year == now.year &&
            s.createdAt.month == now.month &&
            s.createdAt.day == now.day)
        .fold<double>(0, (sum, s) => sum + s.cashPaidUsd + s.depositUsedUsd);
  }

  /// Total pending credit across all sales in current filter
  double get totalPendingCredit {
    if (isLoading || error != null) return 0.0;
    return sales.fold<double>(0, (sum, s) => sum + s.creditAddedUsd);
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class ReportsNotifier extends Notifier<ReportsState> {
  @override
  ReportsState build() {
    Future.microtask(() => _fetch());
    return const ReportsState();
  }

  Future<void> _fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await ref.read(supabaseSessionProvider.future);
      if (session == null) {
        state = state.copyWith(sales: [], isLoading: false);
        return;
      }

      final since = state.dateFilter.since;
      final response = since != null
          ? await Supabase.instance.client
              .from('sales')
              .select('*, customers(name)')
              .eq('merchant_id', session.user.id)
              .gte('created_at', since.toIso8601String())
              .order('created_at', ascending: false)
          : await Supabase.instance.client
              .from('sales')
              .select('*, customers(name)')
              .eq('merchant_id', session.user.id)
              .order('created_at', ascending: false);
      final sales =
          (response as List).map((d) => SaleModel.fromJson(d)).toList();
      state = state.copyWith(sales: sales, isLoading: false);
    } catch (e, st) {
      state = state.copyWith(error: e, isLoading: false);
    }
  }

  void setDateFilter(ReportsDateFilter filter) {
    state = state.copyWith(dateFilter: filter);
    _fetch();
  }

  Future<void> refresh() => _fetch();
}

// ─── Provider ────────────────────────────────────────────────────────────────

final reportsProvider = NotifierProvider<ReportsNotifier, ReportsState>(
  ReportsNotifier.new,
);
