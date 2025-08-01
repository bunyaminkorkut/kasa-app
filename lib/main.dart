import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'firebase_options.dart';

// Global nesne
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Bildirim kanalı
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'kasa_app_notifications',
  'Kasa App Bildirimleri',
  description: 'Kasa uygulaması bildirim kanalı',
  importance: Importance.max,
);

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitSettings =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      print('Bildirim tıklandı: ${response.id}, payload: $payload');

      if (payload != null && payload.isNotEmpty) {
        // Payload query string gibi gönderiliyorsa bunu parse edelim
        final data = Uri.splitQueryString(payload);

        final type = data['type'];
        print('Bildirim türü: $type');

        switch (type) {
          case 'new_request':
            // Bildirim üzerinden Notifications sayfasına git
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialIndex: 1),
              ),
              (route) => false,
            );
            break;

          case 'group_expense':
            // Örnek: group_id parametresiyle harcama detay sayfasına yönlendirme yapabilirsin
            final groupId = data['group_id'];
            if (groupId != null) {
              // navigatorKey.currentState?.push(... detay sayfası ...)
              print('Grup ID: $groupId için yönlendir.');
            }
            break;

          // İstersen diğer bildirim tipleri için case ekle
          default:
            print('Bilinmeyen bildirim türü: $type');
            break;
        }
      } else {
        print('Bildirim payload boş veya null.');
      }
    },
  );

  // Foreground mesaj dinleme
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final payload = Uri(queryParameters: data).query; // Map -> query string

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    }
  });
}

// Arka planda gelen mesajlar için (headless)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background mesaj alındı: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initLocalNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
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
  late StreamSubscription _linkSubscription;

  @override
  void initState() {
    super.initState();
    setupFirebaseMessaging();

    _linkSubscription = EventChannel('com.bunyamin.kasa/universal_link')
        .receiveBroadcastStream()
        .listen((dynamic link) {
          print('Universal Link geldi: $link');
        });
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  void setupFirebaseMessaging() async {
    // Bildirim izni iste
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Bildirim izni verildi');

      // APNs token (iOS)
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        print('APNs token: $apnsToken');
        // Sunucuya kaydetmek istersen burada çağır
      }

      // Firebase token
      final fcmToken = await _messaging.getToken();
      print('FCM token: $fcmToken');
    } else {
      print('Bildirim izni reddedildi');
    }

    // App açıkken gelen mesajları dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    });
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
          navigatorKey: navigatorKey,
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
