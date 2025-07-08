import 'package:dio/dio.dart';
import 'package:fd_downloader/providers/api_base_url_provider.dart';
import 'package:fd_downloader/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ApiBaseUrlScreen extends ConsumerStatefulWidget {
  const ApiBaseUrlScreen({super.key});

  @override
  ConsumerState<ApiBaseUrlScreen> createState() => _ApiBaseUrlScreenState();
}

class _ApiBaseUrlScreenState extends ConsumerState<ApiBaseUrlScreen> {
  final TextEditingController apiBaseUrlController = TextEditingController();

  final String healthCheckEndpoint = "/health_check";
  bool isTesting = false;

  Future<bool> _testConnection(String baseUrl, WidgetRef ref) async {
    try {
      setState(() => isTesting = true);
      final dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 2)));
      final fullUrl = "$baseUrl$healthCheckEndpoint";

      final response = await dio.get(
        fullUrl,
        options: Options(
          sendTimeout: Duration(seconds: 2),
          receiveTimeout: Duration(seconds: 2),
        ),
      );

      if (response.statusCode == 200) {
        ref.read(apiBaseUrlProvider.notifier).saveBaseUrl(baseUrl);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      setState(() => isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(FontAwesomeIcons.vihara),
        title: Text(
          "Fd Downloader",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("assets/logo.png", width: 150),
                const SizedBox(height: 20),
                Text(
                  "Set up your API base URL",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  "Enter the base URL for your API, e.g. http://192.168.1.2:8002",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: apiBaseUrlController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'API Base URL',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(0, 48), // Height
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(isTesting ? "Testing..." : "Test Connection"),
                  onPressed: () async {
                    final result = await _testConnection(
                      apiBaseUrlController.text,
                      ref,
                    );

                    if (!context.mounted) return;
                    if (result) {
                      SnackbarHelper.showCustomSnackbar(
                        context: context,
                        message: "Connection successful",
                        type: SnackbarType.success,
                      );
                    } else {
                      SnackbarHelper.showCustomSnackbar(
                        context: context,
                        message: "Connection failed",
                        type: SnackbarType.error,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
