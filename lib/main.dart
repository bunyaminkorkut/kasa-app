// main.dart

import 'dart:async';
import 'package:app_links/app_links.dart';
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
import 'package:kasa_app/presentation/group_uni_link/group_uni_link.dart';
import 'package:kasa_app/presentation/home/home.dart';
import 'package:kasa_app/presentation/login/login.dart';
import 'package:kasa_app/presentation/register/register.dart';
import 'package:kasa_app/presentation/splash/splash_view.dart';
import 'firebase_options.dart';

// Bildirim ayarları
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'kasa_app_notifications',
  'Kasa App Bildirimleri',
  description: 'Kasa uygulaması bildirim kanalı',
  importance: Importance.max,
);

// Bildirim kurulumu
Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInitSettings =
      DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitSettings,
    iOS: iosInitSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        final data = Uri.splitQueryString(payload);
        final type = data['type'];
        switch (type) {
          case 'new_request':
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialIndex: 1),
              ),
              (route) => false,
            );
            break;
          case 'group_expense':
            final groupId = data['group_id'];
            if (groupId != null) {
              print('Grup ID: $groupId için yönlendir.');
            }
            break;
          default:
            print('Bilinmeyen bildirim türü: $type');
        }
      }
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    if (notification != null) {
      final payload = Uri(queryParameters: data).query;
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    }
  });
}

// Background mesaj işleyici
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background mesaj alındı: ${message.messageId}');
}

// Main fonksiyonu
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initLocalNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  runApp(MyApp(secureStorage: secureStorage));
}

class MyApp extends StatefulWidget {
  final FlutterSecureStorage secureStorage;

  const MyApp({super.key, required this.secureStorage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<Uri>? _appLinksSubscription;
  StreamSubscription<dynamic>? _platformChannelSubscription;
  String? _pendingGroupToken;
  late AppLinks _appLinks;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    print('🔹 MyApp initState başladı');
    WidgetsBinding.instance.addObserver(this);
    _appLinks = AppLinks();
    _setupFirebaseMessaging();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    print('🔹 Deep link initialization başladı');

    // iOS için daha güvenilir initial link kontrolü
    await _checkInitialLink();

    // Runtime link listeners
    _setupDeepLinkListeners();

    // Initialization tamamlandı
    setState(() {
      _isInitializing = false;
    });

    print(
      '🔹 Deep link initialization tamamlandı - final token: $_pendingGroupToken',
    );
  }

  Future<void> _checkInitialLink() async {
    String? groupToken;

    // Yöntem 1: app_links (birden fazla deneme)
    for (int i = 0; i < 3; i++) {
      try {
        print('🔹 app_links deneme ${i + 1}...');
        await Future.delayed(
          Duration(milliseconds: i * 100),
        ); // Progressive delay

        final uri = await _appLinks.getInitialLink();
        print('🔹 app_links sonucu (deneme ${i + 1}): $uri');

        if (uri != null) {
          groupToken = uri.queryParameters['group_token'];
          if (groupToken != null && groupToken.isNotEmpty) {
            print('🔹 app_links SUCCESS - token: $groupToken');
            break;
          }
        }
      } catch (e) {
        print('🔹 app_links deneme ${i + 1} hatası: $e');
      }
    }

    // Yöntem 2: Platform-specific methods
    if (groupToken == null) {
      try {
        print('🔹 Platform channel deneniyor...');
        const platform = MethodChannel('com.bunyamin.kasa/deep_link');
        final String? initialLink = await platform.invokeMethod(
          'getInitialLink',
        );
        print('🔹 Platform channel sonucu: $initialLink');

        if (initialLink != null && initialLink.isNotEmpty) {
          final uri = Uri.tryParse(initialLink);
          groupToken = uri?.queryParameters['group_token'];
          print('🔹 Platform channel token: $groupToken');
        }
      } catch (e) {
        print('🔹 Platform channel hatası: $e');
      }
    }

    // Yöntem 3: iOS-specific UserActivity check
    if (groupToken == null &&
        Theme.of(context).platform == TargetPlatform.iOS) {
      try {
        print('🔹 iOS UserActivity deneniyor...');
        const platform = MethodChannel('com.bunyamin.kasa/ios_activity');
        final String? activityUrl = await platform.invokeMethod(
          'getUserActivityUrl',
        );
        print('🔹 iOS UserActivity sonucu: $activityUrl');

        if (activityUrl != null && activityUrl.isNotEmpty) {
          final uri = Uri.tryParse(activityUrl);
          groupToken = uri?.queryParameters['group_token'];
          print('🔹 iOS UserActivity token: $groupToken');
        }
      } catch (e) {
        print('🔹 iOS UserActivity hatası: $e');
      }
    }

    if (groupToken != null && groupToken.isNotEmpty) {
      setState(() {
        _pendingGroupToken = groupToken;
      });
      print('🔹 Initial token set: $groupToken');
    } else {
      print('🔹 No initial token found');
    }
  }

  void _setupDeepLinkListeners() {
    // app_links listener
    _appLinksSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('🔹 app_links stream geldi: $uri');
        _handleDeepLink(uri.toString());
      },
      onError: (err) {
        print('🔹 app_links stream hatası: $err');
      },
    );

    // Platform channel listener (EventChannel)
    _platformChannelSubscription =
        const EventChannel(
          'com.bunyamin.kasa/universal_link',
        ).receiveBroadcastStream().listen(
          (dynamic link) {
            print('🔹 Platform channel geldi: $link');
            _handleDeepLink(link as String?);
          },
          onError: (error) {
            print('🔹 Platform channel hatası: $error');
          },
        );
  }

  void _handleDeepLink(String? link) {
    print('🔹 Deep link işleniyor: $link');
    if (link == null || link.isEmpty) return;

    try {
      final uri = Uri.tryParse(link);
      final groupToken = uri?.queryParameters['group_token'];
      print('🔹 Parsed group token: $groupToken');

      if (groupToken != null && groupToken.isNotEmpty) {
        setState(() {
          _pendingGroupToken = groupToken;
        });
        print('🔹 Group token state güncellendi: $groupToken');

        // Immediate navigation for runtime links
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToGroupLink();
        });
      }
    } catch (e) {
      print('🔹 Deep link parse hatası: $e');
    }
  }

  void _navigateToGroupLink() {
    if (_pendingGroupToken == null) {
      print('🔹 Navigate: pending token null');
      return;
    }

    final context = navigatorKey.currentContext;
    final tokenToPass = _pendingGroupToken;

    print('🔹 Navigate: context=$context, token=$tokenToPass');

    if (context != null && mounted) {
      print('🔹 Navigating to group link with token: $tokenToPass');
      setState(() {
        _pendingGroupToken = null;
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => KasaSplashView(
            logo: Image.asset('assets/icon.png', width: 120, height: 120),
            isSplash: false,
            groupToken: tokenToPass,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔹 App lifecycle: $state, pending token: $_pendingGroupToken');
    if (state == AppLifecycleState.resumed && _pendingGroupToken != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _navigateToGroupLink(),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLinksSubscription?.cancel();
    _platformChannelSubscription?.cancel();
    super.dispose();
  }

  void _setupFirebaseMessaging() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await _messaging.getToken();
        if (fcmToken != null) print('FCM token: $fcmToken');
      }
    } catch (e) {
      print('Firebase messaging setup hatası: $e');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      final type = data['type'];

      switch (type) {
        case 'new_request':
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomePage(initialIndex: 1),
            ),
            (route) => false,
          );
          break;
        case 'group_expense':
          final groupId = data['group_id'];
          if (groupId != null) {
            print('Navigate to group: $groupId');
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
      '🔹 Build çağrıldı - initializing: $_isInitializing, pending token: $_pendingGroupToken',
    );

    // Show loading while checking for initial links
    if (_isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking deep links...'),
              ],
            ),
          ),
        ),
      );
    }

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
          home: KasaSplashView(
            logo: Image.asset('assets/icon.png', width: 120, height: 120),
            isSplash: true,
            groupToken: _pendingGroupToken,
          ),
          routes: {
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/splash': (context) => KasaSplashView(
              logo: Image.asset('assets/icon.png', width: 120, height: 120),
            ),
            '/group_uni_link': (context) {
              final args = ModalRoute.of(context)!.settings.arguments as String;
              return GroupUniLink(groupToken: args);
            },
          },
        ),
      ),
    );
  }
}
