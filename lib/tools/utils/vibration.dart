import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class VibrationPhone {
  VibrationPhone._internal();
  factory VibrationPhone() => _getInstance();
  static VibrationPhone get instance => _getInstance();
  static VibrationPhone _instance;
  static VibrationPhone _getInstance() {
    if (_instance == null) {
      _instance = new VibrationPhone._internal();
    }
    return _instance;
  }

  static AudioPlayer fixedPlayer =
      AudioPlayer(playerId: 'cobiz_play_AudioCache');
  static AudioCache player =
      AudioCache(respectSilence: true, fixedPlayer: fixedPlayer);

  static play() async {
    await player.load('msg_sound.mp3');
    await player.play('msg_sound.mp3', volume: 10.0);
  }

  static clearCache() {
    player.clearCache();
  }

  static checkVibrationPhone({int duration = 500, int amplitude = -1}) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: duration, amplitude: amplitude);
    }
  }

  static hasAmplitudeControl() async {
    if (await Vibration.hasAmplitudeControl()) {
      Vibration.vibrate(amplitude: 128);
    }
  }

  static cancelVibration() {
    Vibration.cancel();
  }
}
