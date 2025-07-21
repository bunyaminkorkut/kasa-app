import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/presentation/home/home.dart';
import 'package:kasa_app/presentation/login/login.dart';
import 'package:kt_dart/collection.dart';

class KasaSplashView extends StatefulWidget {
  const KasaSplashView({super.key, required this.logo, this.isSplash = true});
  final Widget? logo;
  final bool isSplash;

  @override
  State<KasaSplashView> createState() => _KasaSplashViewState();
}

class _KasaSplashViewState extends State<KasaSplashView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool _navigated = false; // Navigation flag

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            lowerBound: 0.75,
            upperBound: 1.0,
            duration: const Duration(seconds: 1),
          )
          ..forward()
          ..repeat(reverse: true, min: 0.85);

    Future.delayed(const Duration(seconds: 1), () async {
      final jwt = await secureStorage.read(key: 'jwt');
      if (jwt != null && jwt.isNotEmpty) {
        if (mounted) {
          context.read<GroupBloc>().addFetchGroups(jwtToken: jwt);
          context.read<GroupBloc>().addFetchGroupRequests(jwtToken: jwt);
        }
      } else {
        if (!_navigated && mounted) {
          _navigated = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    });
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
        // Her iki success flag'ini ve fetching durumunu da dinle
        return previous.hasFetchedGroupsSucceeded !=
                current.hasFetchedGroupsSucceeded ||
            previous.hasFetchedRequestsSucceeded !=
                current.hasFetchedRequestsSucceeded ||
            (previous.isFetchingData != current.isFetchingData &&
                !current.isFetchingData);
      },
      listener: (context, state) {
        if (!mounted) return;

        // Eğer zaten yönlendirme yapılmışsa, tekrar yapma
        if (_navigated) return;

        // Eğer iki veri de başarıyla geldi ise home sayfasına git
        if (state.hasFetchedGroupsSucceeded &&
            state.hasFetchedRequestsSucceeded) {
          _navigated = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
        // Eğer veri çekme işlemi bitti ve en az birinde hata varsa login'e yönlendir
        else if (!state.isFetchingData &&
            (state.getGroupsFailureOrGroups.fold(
                  () => false,
                  (either) => either.isLeft(),
                ) ||
                state.getGroupRequestsFailureOrRequests.fold(
                  () => false,
                  (either) => either.isLeft(),
                ))) {
          _navigated = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
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
          body: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Sadece içeriğin kapladığı kadar yer
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
                if (!widget.isSplash) ...[
                  const SizedBox(height: 16),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Almost there...',
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    pause: const Duration(milliseconds: 1000),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
