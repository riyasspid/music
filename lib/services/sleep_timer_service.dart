// ────────────────────────────────────────────────────────────────────────────
// SleepTimerService — countdown timer that stops playback
// ────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:get/get.dart';
import 'audio_provider.dart';

class SleepTimerService extends GetxController {
  Timer? _timer;
  final RxInt remainingSeconds = 0.obs;
  final RxBool isActive = false.obs;

  void startTimer(int seconds) {
    cancelTimer();
    remainingSeconds.value = seconds;
    isActive.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remainingSeconds.value--;
      if (remainingSeconds.value <= 0) {
        _onTimerEnd();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    remainingSeconds.value = 0;
    isActive.value = false;
  }

  void _onTimerEnd() {
    cancelTimer();
    Get.find<AudioProvider>().stop();
  }

  String get formattedRemaining {
    final m = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
