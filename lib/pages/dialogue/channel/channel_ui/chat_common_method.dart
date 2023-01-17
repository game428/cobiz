import 'package:audioplayers/audioplayers.dart';

class ChatCommonMethod {
  //关闭语音
  static stopAudioPlayer(AudioPlayer audioPlayer) {
    if (audioPlayer?.state == AudioPlayerState.PLAYING) {
      audioPlayer?.stop();
    }
  }
}
