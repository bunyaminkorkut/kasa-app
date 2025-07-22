import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_app/application/auth/auth_cubit.dart';

import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/domain/group/i_group_repository.dart';
import 'package:kasa_app/infrastructure/group/impl_group_service.dart';
import 'package:kasa_app/presentation/home/home.dart';
import 'package:kasa_app/presentation/login/login.dart';
import 'package:kasa_app/presentation/register/register.dart';
import 'package:kasa_app/presentation/splash/splash_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const secureStorage = FlutterSecureStorage();

  runApp(MyApp(secureStorage: secureStorage));
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage secureStorage;

  const MyApp({super.key, required this.secureStorage});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IGroupRepository>(
      create: (_) => GroupService(),  // Somut IGroupRepository sağlayıcısı
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(secureStorage: secureStorage),
          ),
          BlocProvider<GroupBloc>(
            create: (context) => GroupBloc(context.read<IGroupRepository>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kasa App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),
          home: const KasaSplashView(logo: FlutterLogo(size: 120), isSplash: true),
          routes: {
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
          },
        ),
      ),
    );
  }
}
