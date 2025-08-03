import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/auth/auth_cubit.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/presentation/group/group_details/group_details_page.dart';
import 'package:kasa_app/presentation/group_uni_link/group_uni_link.dart';
import 'package:kasa_app/presentation/home/home.dart';
import 'package:kasa_app/presentation/login/login.dart';

class KasaSplashView extends StatefulWidget {
  const KasaSplashView({
    super.key,
    required this.logo,
    this.isSplash = true,
    this.groupToken,
  });
  final Widget? logo;
  final bool isSplash;
  final String? groupToken;

  @override
  State<KasaSplashView> createState() => _KasaSplashViewState();
}

class _KasaSplashViewState extends State<KasaSplashView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool _navigated = false;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    print('SplashView başlatıldı - groupToken: ${widget.groupToken}');

    _controller =
        AnimationController(
            vsync: this,
            lowerBound: 0.75,
            upperBound: 1.0,
            duration: const Duration(seconds: 1),
          )
          ..forward()
          ..repeat(reverse: true, min: 0.85);

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final jwt = await secureStorage.read(key: 'jwt');

      if (jwt != null && jwt.isNotEmpty) {
        if (mounted) {
          context.read<AuthCubit>().getUser(jwt);

          // FCM token'ı gönder
          try {
            final fcmToken = await _messaging.getToken();
            if (fcmToken != null && mounted) {
              context.read<AuthCubit>().sendFCMToken(fcmToken, jwt);
            }
          } catch (e) {
            print('FCM token hatası: $e');
          }

          context.read<GroupBloc>().addFetchGroupRequests(jwtToken: jwt);
          if (widget.groupToken != null && widget.groupToken!.isNotEmpty) {
            context.read<GroupBloc>().addAddGroupWithGroupToken(
              jwtToken: jwt,
              groupToken: widget.groupToken!,
            );
            return; // BlocListener sonucu yönlendirecek
          } else {
            context.read<GroupBloc>().addFetchGroups(jwtToken: jwt);
          }
        }
      } else {
        if (mounted && !_navigated) {
          _navigated = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print('Splash initialization hatası: $e');
      if (mounted && !_navigated) {
        _navigated = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) {
        if (widget.groupToken != null) {
          return previous.isAddingGroupWithGroupToken !=
                  current.isAddingGroupWithGroupToken &&
              !current.isAddingGroupWithGroupToken &&
              current.addGroupWithGroupTokenFailureOrGroup.isSome();
        }

        return previous.hasFetchedGroupsSucceeded !=
                current.hasFetchedGroupsSucceeded ||
            previous.hasFetchedRequestsSucceeded !=
                current.hasFetchedRequestsSucceeded ||
            (previous.isFetchingData != current.isFetchingData &&
                !current.isFetchingData);
      },
      listener: (context, state) {
        if (!mounted || _navigated) return;
        if (widget.groupToken != null) {
          final result = state.addGroupWithGroupTokenFailureOrGroup;
          if (result.isSome()) {
            result.fold(
              () {},
              (either) => either.fold(
                (failure) {
                  _navigated = true;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                (group) {
                  _navigated = true;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GroupDetailsPage(groupId: group.newGroupId),
                    ),
                  );
                },
              ),
            );
          }
        } else {
          if (state.hasFetchedGroupsSucceeded &&
              state.hasFetchedRequestsSucceeded) {
            _navigated = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
            return;
          }

          if (!state.isFetchingData) {
            final hasGroupError = state.getGroupsFailureOrGroups.fold(
              () => false,
              (either) => either.isLeft(),
            );

            final hasRequestError = state.getGroupRequestsFailureOrRequests
                .fold(() => false, (either) => either.isLeft());

            if (hasGroupError || hasRequestError) {
              _navigated = true;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _controller.value,
                      child: widget.logo ?? const SizedBox(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (!widget.isSplash)
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        widget.groupToken != null
                            ? 'Joining group...'
                            : 'Almost there...',
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: const Duration(milliseconds: 1000),
                  )
                else
                  const SizedBox(
                    height: 4,
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
