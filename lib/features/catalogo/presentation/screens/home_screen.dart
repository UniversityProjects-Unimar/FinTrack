import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:fin_track/features/autenticacao/presentation/screens/login_screen.dart';
import 'package:fin_track/features/catalogo/presentation/screens/new_transaction_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _recentTransactions = [
    Transaction(
      id: 't1',
      amount: 80,
      category: 'Mercado',
      description: 'Compra semanal',
      createdAt: DateTime(2026, 4, 1),
    ),
    Transaction(
      id: 't2',
      amount: 35,
      category: 'Transporte',
      description: 'Combustivel',
      createdAt: DateTime(2026, 4, 2),
    ),
    Transaction(
      id: 't3',
      amount: 120,
      category: 'Lazer',
      description: 'Cinema e lanche',
      createdAt: DateTime(2026, 4, 4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(Icons.login),
            tooltip: 'Ir para login',
          ),
        ],
      ),
      body: _buildDashboard(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const NewTransactionScreen(),
            ),
          );
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
          Expanded(
            child: ListView.separated(
              itemCount: _recentTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _recentTransactions[index];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: const CircleAvatar(child: Icon(Icons.attach_money)),
                  title: Text(item.category),
                  subtitle: Text(item.description),
                  trailing: Text('R\$ ${item.amount.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
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
