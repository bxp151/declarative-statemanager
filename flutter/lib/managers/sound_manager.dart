// FILE: sound_manager.dart

import 'package:just_audio/just_audio.dart';

class SoundManager {
  final AudioPlayer audioPlayer;

  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal() : audioPlayer = AudioPlayer();

  final Map<String, String> soundNamesToFileLocations = {
    'step_correct': 'assets/sounds/step_correct.mp3',
    'step_incorrect': 'assets/sounds/step_incorrect.mp3',
    'problem_correct': 'assets/sounds/problem_correct.mp3',
    'problem_incorrect': 'assets/sounds/problem_incorrect.mp3',
  };

  Future<void> playSoundBasedOnName({required String soundName}) async {
    // await audioPlayer.setFilePath(soundNamesToFileLocations[soundName]!);
    await audioPlayer.setAudioSource(
        AudioSource.asset(soundNamesToFileLocations[soundName]!));
    audioPlayer.play();
  }
}
