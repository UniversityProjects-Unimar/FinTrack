import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionsProvider extends ChangeNotifier {
  TransactionsProvider({List<Transaction>? seed})
    : _seed = List<Transaction>.unmodifiable(seed ?? const []);

  final List<Transaction> _seed;

  final List<Transaction> _items = [];
  String _categoryFilter = '';
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  List<Transaction> get items {
    if (_categoryFilter.isEmpty) {
      return List<Transaction>.unmodifiable(_items);
    }

    return List<Transaction>.unmodifiable(
      _items.where((t) => t.category == _categoryFilter),
    );
  }

  String get categoryFilter => _categoryFilter;

  List<String> get categories {
    final set = _items.map((t) => t.category).toSet();
    final list = set.toList()..sort();
    return List<String>.unmodifiable(list);
  }

  bool get loading => _loading;
  String? get error => _error;

  void filterByCategory(String category) {
    if (_categoryFilter == category) return;
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilter() {
    if (_categoryFilter.isEmpty) return;
    _categoryFilter = '';
    notifyListeners();
  }

  Future<void> load() async {
    if (_loading || _loaded) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      _items
        ..clear()
        ..addAll(_seed);
      _loaded = true;
    } catch (e) {
      _error = 'Erro ao carregar transações: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required double amount,
    required String category,
    required String description,
    required DateTime createdAt,
  }) async {
    final tx = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      description: description,
      createdAt: createdAt,
    );

    _items.insert(0, tx);
    notifyListeners();
  }

  void removeById(String id) {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
