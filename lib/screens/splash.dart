import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:convogen/providers/app_settings_provider.dart';
import 'package:convogen/router/router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appSettingsProvider, (previous, next) {
      Future.delayed(const Duration(seconds: 3), () {
        GoRouter.of(context).replace(homeRoute);
      });
    });
    return const Scaffold(body: Center(child: ApplicationLogo()));
  }
}

class ApplicationLogo extends StatelessWidget {
  final double? height;
  final double? width;
  const ApplicationLogo({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? SvgPicture.asset(
            "assets/logo/convogen-light.svg",
            width: width ?? 200,
            height: height,
          )
        : SvgPicture.asset(
            "assets/logo/convogen-dark.svg",
            width: width ?? 200,
            height: height,
          );
  }
}
