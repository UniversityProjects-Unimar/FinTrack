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
                    'R\$ 2.460,00',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _SummaryCard(
                  title: 'Receitas',
                  value: 'R\$ 3.200,00',
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Despesas',
                  value: 'R\$ 740,00',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _CategoryFilters(),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<TransactionsProvider>(
              builder: (context, store, child) {
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
                                userId: context.read<AuthProvider>().user!.id,
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
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.attach_money),
                      ),
                      title: Text(item.category),
                      subtitle: Text(item.description),
                      trailing: Text('R\$ ${item.amount.toStringAsFixed(2)}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
