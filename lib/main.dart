import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_app/application/auth/auth_cubit.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/application/photo/photo_cubit.dart';
import 'package:kasa_app/domain/group/i_group_repository.dart';
import 'package:kasa_app/domain/photo/i_photo_repository.dart';
import 'package:kasa_app/infrastructure/group/impl_group_service.dart';
import 'package:kasa_app/infrastructure/photo/impl_photo_service.dart';
import 'package:kasa_app/presentation/home/home.dart';
import 'package:kasa_app/presentation/login/login.dart';
import 'package:kasa_app/presentation/register/register.dart';
import 'package:kasa_app/presentation/splash/splash_view.dart';
import 'package:kasa_app/setup_bindings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupBindings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const secureStorage = FlutterSecureStorage();

  runApp(MyApp(secureStorage: secureStorage));
}

class MyApp extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const MyApp({super.key, required this.secureStorage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // // iOS için izin iste
    // _messaging.requestPermission();

    // // Token'ı al
    // _messaging.getToken().then((token) {
    //   print("FCM Token: $token");
    //   // Bu token'ı backend'e kayıt edip push bildirim gönderiminde kullanabilirsin
    // });

    // // Uygulama açıkken gelen mesajlar için listener
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Foreground mesajı alındı: ${message.notification?.title}');
    //   // İstersen local notification göster
    // });

    // // Uygulama arka plandayken veya kapalıyken tıklanarak açılan mesajlar için
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('Bildirim tıklanarak açıldı');
    //   // Burada kullanıcıyı ilgili sayfaya yönlendirebilirsin
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IGroupRepository>(create: (_) => GroupService()),
        RepositoryProvider<IPhotoRepository>(create: (_) => PhotoService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(secureStorage: widget.secureStorage),
          ),
          BlocProvider<GroupBloc>(
            create: (context) => GroupBloc(context.read<IGroupRepository>()),
          ),
          BlocProvider<PhotoCubit>(
            create: (context) => PhotoCubit(context.read<IPhotoRepository>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kasa App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),
          home: const KasaSplashView(
            logo: FlutterLogo(size: 120),
            isSplash: true,
          ),
          routes: {
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/splash': (context) =>
                const KasaSplashView(logo: FlutterLogo(size: 120)),
          },
        ),
      ),
    );
  }
}
