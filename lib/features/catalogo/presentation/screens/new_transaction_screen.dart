import 'package:fin_track/features/autenticacao/state/auth_provider.dart';
import 'package:fin_track/features/catalogo/state/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _categoryFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  bool _isIncome = false;
  String _selectedCategory = 'Mercado';
  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  double? _parseAmount(String input) {
    final text = input.trim().replaceAll(' ', '');
    if (text.isEmpty) return null;
    if (!RegExp(r'^[0-9.,]+$').hasMatch(text)) return null;

    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');

    String normalized;

    if (lastComma != -1 && lastDot != -1) {
      if (lastComma > lastDot) {
        normalized = text.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = text.replaceAll(',', '');
      }
    } else if (lastComma != -1) {
      final digitsAfter = text.length - lastComma - 1;
      if (digitsAfter == 0) return null;

      normalized = digitsAfter == 3
          ? text.replaceAll(',', '')
          : text.replaceAll(',', '.');
    } else if (lastDot != -1) {
      final digitsAfter = text.length - lastDot - 1;
      if (digitsAfter == 0) return null;

      normalized = digitsAfter == 3 ? text.replaceAll('.', '') : text;
    } else {
      normalized = text;
    }

    return double.tryParse(normalized);
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    _categoryFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;

    final categories = _isIncome
        ? const <String>[
            'Salário',
            'Freelance',
            'Investimentos',
            'Reembolso',
            'Outros ganhos',
          ]
        : const <String>[
            'Mercado',
            'Transporte',
            'Lazer',
            'Saúde',
            'Casa',
            'Educação',
            'Assinaturas',
          ];

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nova transação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Gasto'),
                          selected: !_isIncome,
                          onSelected: (selected) {
                            if (!selected) return;
                            setState(() {
                              _isIncome = false;
                              _selectedCategory = 'Mercado';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Ganho'),
                          selected: _isIncome,
                          onSelected: (selected) {
                            if (!selected) return;
                            setState(() {
                              _isIncome = true;
                              _selectedCategory = 'Salário';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_categoryFocus);
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: '0,00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Informe o valor';
                  }

                  final parsed = _parseAmount(text);
                  if (parsed == null) {
                    return 'Informe um valor válido';
                  }
                  if (parsed <= 0) {
                    return 'O valor deve ser maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                focusNode: _categoryFocus,
                items: [
                  for (final c in categories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                    FocusScope.of(context).requestFocus(_descriptionFocus);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Compra no mercado',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Data'),
                  subtitle: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
                ),
              ),
              SizedBox(height: isSmall ? 16 : 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar transação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthProvider>();
      final txProvider = context.read<TransactionsProvider>();
      final userId = auth.user?.id;
      if (userId == null) {
        throw StateError('Usuário não autenticado.');
      }

      await Future<void>.delayed(const Duration(milliseconds: 250));

      final valueText = _valueController.text.trim();
      final parsed = _parseAmount(valueText);
      if (parsed == null) {
        throw StateError('Valor inválido.');
      }
      final signedAmount = _isIncome ? parsed : -parsed;

      await txProvider.add(
        userId: userId,
        amount: signedAmount,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        createdAt: _selectedDate,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação salva com sucesso')),
      );
      context.pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
