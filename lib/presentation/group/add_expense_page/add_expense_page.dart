import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/domain/group/create_expense_data.dart';
import 'package:kasa_app/domain/group/group_data.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakamları al
    String digitsOnly = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Değer kuruşlu biçimde olacak: 1000 -> 10.00 TL
    double value = double.parse(digitsOnly) / 100;

    // Türk Lirası biçimi: 1.000,50
    final newText = _formatter.format(value).trim();

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CreateExpensePage extends StatefulWidget {
  final GroupData group;

  const CreateExpensePage({super.key, required this.group});

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();

  final Set<String> _selectedMemberIds = {};
  bool _isSplitEqually = true;

  @override
  void initState() {
    super.initState();
    // Tüm üyeleri varsayılan olarak seçili yap
    _selectedMemberIds.addAll(widget.group.members.map((m) => m.id));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final note = _noteController.text.trim();

      // Türk formatı: 1.000,50 → 1000.50
      final cleanedAmount = _amountController.text
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .replaceAll('₺', '')
          .replaceAll('TL', '')
          .trim();

      final amount = double.tryParse(cleanedAmount) ?? 0.0;

      final selectedMembers = widget.group.members
          .where((m) => _selectedMemberIds.contains(m.id))
          .toList();

      final FlutterSecureStorage secureStorage = FlutterSecureStorage();
      final jwt = await secureStorage.read(key: 'jwt');
      if (jwt == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("JWT bulunamadı")));
        return;
      }

      // Kullanıcıları ExpenseUserData'ya çevir
      final users = selectedMembers.map((member) {
        return ExpenseUserData(
          userId: member.id,
          amount: _isSplitEqually
              ? (amount / selectedMembers.length)
              : (amount / selectedMembers.length),
        );
      }).toList();

      final expense = CreateExpenseData(
        groupId: widget.group.id,
        totalAmount: amount,
        note: note,
        paymentTitle: title,
        users: users,
        billImageUrl: null,
      );

      context.read<GroupBloc>().addCreateExpense(
        jwtToken: jwt,
        expenseData: expense,
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Gider Oluştur"),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    body: BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.createExpenseFailOrSuccess != current.createExpenseFailOrSuccess,
      listener: (context, state) {
        state.createExpenseFailOrSuccess.fold(
          () => null,
          (success) {
            if (success) {
              Navigator.of(context).pop(); // Başarılıysa geri dön
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Gider oluşturulamadı. Lütfen tekrar deneyin."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Başlık gerekli' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Not (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [CurrencyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Tutar',
                hintText: '0,00',
                border: OutlineInputBorder(),
                prefixText: '₺ ',
                suffixText: 'TL',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Tutar gerekli';
                final cleaned = value
                    .replaceAll('.', '')
                    .replaceAll(',', '.')
                    .replaceAll('₺', '')
                    .replaceAll('TL', '')
                    .trim();
                final amount = double.tryParse(cleaned);
                if (amount == null || amount <= 0) {
                  return 'Geçerli bir tutar giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "Gideri paylaşacak üyeler",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...widget.group.members.map((member) {
              final isChecked = _selectedMemberIds.contains(member.id);
              return CheckboxListTile(
                value: isChecked,
                title: Text(member.fullname),
                subtitle: Text(member.email),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedMemberIds.add(member.id);
                    } else {
                      _selectedMemberIds.remove(member.id);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isSplitEqually,
              onChanged: (val) {
                setState(() {
                  _isSplitEqually = val ?? true;
                });
              },
              title: const Text(
                "Gideri eşit şekilde paylaş",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            BlocBuilder<GroupBloc, GroupState>(
              builder: (context, state) {
                if (state.creatingExpense) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Gideri Kaydet",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
