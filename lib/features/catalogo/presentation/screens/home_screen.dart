import 'package:fin_track/features/autenticacao/state/auth_provider.dart';
import 'package:fin_track/features/catalogo/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  String _formatMoney(double value) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    final text = abs.toStringAsFixed(2).replaceAll('.', ',');
    return '${sign}R\$ $text';
  }

  String _formatTxAmount(double amount) {
    final absText = amount.abs().toStringAsFixed(2).replaceAll('.', ',');
    if (amount >= 0) {
      return 'R\$ $absText';
    }
    return '-R\$ $absText';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userId = context.read<AuthProvider>().user?.id;
        if (userId != null) {
          context.read<TransactionsProvider>().load(userId: userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _buildDashboard(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/transacoes/nova');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova'),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return Consumer<TransactionsProvider>(
      builder: (context, store, child) {
        final allItems = store.allItems;
        final receitas = allItems
            .where((t) => t.amount > 0)
            .fold<double>(0, (sum, t) => sum + t.amount);
        final despesas = allItems
            .where((t) => t.amount < 0)
            .fold<double>(0, (sum, t) => sum + t.amount.abs());
        final saldo = receitas - despesas;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo total'),
                      Text(
                        _formatMoney(saldo),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Receitas',
                      value: _formatMoney(receitas),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Despesas',
                      value: _formatMoney(despesas),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _CategoryFilters(),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (store.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (store.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 8),
                            Text(store.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<TransactionsProvider>().load(
                                    userId: context
                                        .read<AuthProvider>()
                                        .user!
                                        .id,
                                    forceReload: true,
                                  ),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    final items = store.items;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma transação encontrada.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final surface = Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest;
                        final dateText = _formatDate(item.createdAt);
                        final descriptionText = item.description.trim();
                        final subtitleText = descriptionText.isEmpty
                            ? dateText
                            : '$descriptionText • $dateText';

                        return ListTile(
                          tileColor: surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: const CircleAvatar(
                            child: Icon(Icons.attach_money),
                          ),
                          title: Text(item.category),
                          subtitle: Text(subtitleText),
                          trailing: Text(
                            _formatTxAmount(item.amount),
                            style: TextStyle(
                              color: item.amount >= 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters();

  @override
  Widget build(BuildContext context) {
    final selectedCategory = context
        .watch<TransactionsProvider>()
        .categoryFilter;

    return Selector<TransactionsProvider, List<String>>(
      selector: (context, store) => store.categories,
      builder: (context, categories, child) {
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: selectedCategory.isEmpty,
                  onSelected: (_) =>
                      context.read<TransactionsProvider>().clearFilter(),
                ),
              ),
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (_) => context
                        .read<TransactionsProvider>()
                        .filterByCategory(category),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
