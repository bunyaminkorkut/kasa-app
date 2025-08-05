import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/auth/auth_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void _logout() {
    context.read<AuthCubit>().logout();
  }

  void _showEditDialog({
    required String title,
    required String initialValue,
    required String labelText,
    required void Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  onSave(value);
                  Navigator.pop(context);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final jwt = context.read<AuthCubit>().state.jwt;
    if (jwt != null) {
      context.read<AuthCubit>().getUser(jwt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!state.isAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ayarlar')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state.user;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (user != null) ...[
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kullanıcı Bilgileri',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 8),
                                Expanded(child: Text(user.fullName)),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(
                                      title: 'Ad Soyad Güncelle',
                                      initialValue: user.fullName,
                                      labelText: 'Ad Soyad',
                                      onSave: (newName) {
                                        context.read<AuthCubit>().updateFullName(newName);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email),
                                const SizedBox(width: 8),
                                Expanded(child: Text(user.email)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.credit_card),
                                const SizedBox(width: 8),
                                Expanded(child: Text(user.iban.isEmpty ? 'IBAN eklenmemiş' : user.iban)),
                                TextButton.icon(
                                  icon: Icon(user.iban.isEmpty ? Icons.add : Icons.edit),
                                  label: Text(user.iban.isEmpty ? 'IBAN Ekle' : 'IBAN Güncelle'),
                                  onPressed: () {
                                    _showEditDialog(
                                      title: 'IBAN Güncelle',
                                      initialValue: user.iban,
                                      labelText: 'IBAN',
                                      onSave: (newIban) {
                                        context.read<AuthCubit>().updateIban(newIban);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ElevatedButton.icon(
                  //   icon: const Icon(Icons.copy),
                  //   label: const Text('JWT Kopyala'),
                  //   onPressed: () {
                  //     secureStorage.read(key: 'jwt').then((jwt) {
                  //       if (jwt != null && jwt.isNotEmpty) {
                  //         Clipboard.setData(ClipboardData(text: jwt));
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text('JWT panoya kopyalandı')),
                  //         );
                  //       } else {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(content: Text('JWT bulunamadı')),
                  //         );
                  //       }
                  //     });
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.blueGrey,
                  //     foregroundColor: Colors.white,
                  //   ),
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
