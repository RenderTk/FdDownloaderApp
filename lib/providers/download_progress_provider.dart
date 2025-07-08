import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadProgressProvider extends Notifier<double> {
  @override
  build() {
    return 0;
  }

  void update(double value) {
    state = value;
  }

  void reset() {
    state = 0;
  }
}

final downloadProgressProvider =
    NotifierProvider<DownloadProgressProvider, double>(
      () => DownloadProgressProvider(),
    );
