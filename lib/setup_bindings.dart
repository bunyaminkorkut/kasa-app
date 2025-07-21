import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void setupBindings() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  for (final renderView in binding.renderViews) {
    renderView.automaticSystemUiAdjustment = false;
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [
    SystemUiOverlay.top,
  ]);
}
