import 'package:fd_downloader/api_base_url_screen.dart';
import 'package:fd_downloader/home_screen.dart';
import 'package:fd_downloader/providers/api_base_url_provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApiBaseUrlSet = ref.watch(apiBaseUrlProvider).valueOrNull != null;

    return MaterialApp(
      title: 'FD Downloader',
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(scheme: FlexScheme.cyanM3),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.cyanM3),
      home: isApiBaseUrlSet ? const HomeScreen() : const ApiBaseUrlScreen(),
    );
  }
}
