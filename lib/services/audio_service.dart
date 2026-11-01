import 'package:audioplayers/audioplayers.dart';

import 'app_state.dart';

class AudioService {
  AudioService(this.state) {
    state.addListener(syncMusic);
  }

  final AppState state;
  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _effects = AudioPlayer();
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(.28);
    await syncMusic();
  }

  Future<void> syncMusic() async {
    try {
      if (state.musicOn) {
        if (_music.state != PlayerState.playing) {
          await _music.play(AssetSource('audio/background_music.wav'));
        }
      } else {
        await _music.pause();
      }
    } catch (_) {
      // The app stays usable if a device cannot play an audio asset.
    }
  }

  Future<void> effect(String name) async {
    if (!state.soundOn) return;
    try {
      await _effects.stop();
      await _effects.play(AssetSource('audio/$name.wav'));
    } catch (_) {}
  }

  Future<void> dispose() async {
    state.removeListener(syncMusic);
    await _music.dispose();
    await _effects.dispose();
  }
}
