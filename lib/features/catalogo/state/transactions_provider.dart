import 'package:fin_track/data/repositories/transaction_repository.dart';
import 'package:fin_track/features/autenticacao/domain/models/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionsProvider extends ChangeNotifier {
  TransactionsProvider({
    required TransactionRepository repository,
    List<Transaction>? seed,
  }) : _repository = repository,
       _seed = List<Transaction>.unmodifiable(seed ?? const []);

  final TransactionRepository _repository;

  final List<Transaction> _seed;

  final List<Transaction> _items = [];
  String _categoryFilter = '';
  bool _loading = false;
  int? _loadedUserId;
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

  Future<void> load({required int userId, bool forceReload = false}) async {
    if (_loading) return;
    if (!forceReload && _loadedUserId == userId) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.seedIfEmpty(userId: userId, seed: _seed);
      final loaded = await _repository.getAll(userId: userId);

      _items
        ..clear()
        ..addAll(loaded);
      _loadedUserId = userId;
    } catch (e) {
      _error = 'Erro ao carregar transações: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required int userId,
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

    try {
      await _repository.upsert(userId: userId, tx: tx);
      _items.insert(0, tx);
      _error = null;
    } catch (e) {
      _error = 'Erro ao salvar transação: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeById({required int userId, required String id}) async {
    try {
      await _repository.deleteById(userId: userId, id: id);
      _items.removeWhere((t) => t.id == id);
      _error = null;
    } catch (e) {
      _error = 'Erro ao remover transação: $e';
    } finally {
      notifyListeners();
    }
  }
}
