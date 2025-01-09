import 'package:audio_service/audio_service.dart';
import 'package:city_sightseeing/main.dart';
import 'package:city_sightseeing/service/provider/audio_map_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // mix in default seek callback implementations

  MyAudioHandler() {
    initializePlayerComponents();
  }

  Future<void> initializePlayerComponents() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  var _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> disposePlayer() async {
    await _player.dispose();
  }

  void initializePlayer() {
    _player = AudioPlayer();
  }

  // The most common callbacks:
  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> skipToQueueItem(int i) => _player.seek(Duration.zero, index: i);

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    await _player.setAudioSource(AudioSource.uri(uri));
  }

//todo - check this
  Future<void> addToQueue(MediaItem mediaItem, {required bool isInQueue, required clearQueue}) async {
    final audioSource = ProgressiveAudioSource(
      Uri.parse(mediaItem.id),
      tag: mediaItem,
    );

    // debugPrint("PLAYLIST DATA ====> START POINT");
    // debugPrint("PLAYLIST DATA ====> addToQueue called with MediaItem ID: ${mediaItem.id}");
    // debugPrint("PLAYLIST DATA ====> isInQueue: $isInQueue");
    // debugPrint("PLAYLIST DATA ====> Source Type: ${_player.audioSource.runtimeType}");
    if(clearQueue){
      // debugPrint("PLAYLIST DATA ====> Clearing queue and starting fresh.");
      // debugPrint("PLAYLIST DATA ====> CLEAR QUEUE");
      await _player.stop();
      final playlist = ConcatenatingAudioSource(children: [audioSource]);
      await _player.setAudioSource(playlist);
      // debugPrint("PLAYLIST DATA ====> New playlist created. Length: 1");
      return;
    }
    if (isInQueue) {
      if (_player.audioSource == null) {
        // debugPrint("PLAYLIST DATA ====> No audio source set. Creating a new playlist.");
        final playlist = ConcatenatingAudioSource(children: [audioSource]);
        await _player.setAudioSource(playlist);
        // debugPrint("PLAYLIST DATA ====> New playlist created. Length: 1");
      } else if (_player.audioSource is ConcatenatingAudioSource) {
        // debugPrint("PLAYLIST DATA ====> Audio source is already a playlist. Adding to queue.");
        final playlist = _player.audioSource as ConcatenatingAudioSource;
        await playlist.add(audioSource); // Ensure this is awaited to reflect properly
        // debugPrint("PLAYLIST DATA ====> New item added to the playlist. Length: ${playlist.length}");
      } else {
        // debugPrint("PLAYLIST DATA ====> Current source is not a playlist. Converting to a playlist.");
        final currentSource = _player.audioSource!;
        final playlist = ConcatenatingAudioSource(children: [currentSource, audioSource]);
        await _player.setAudioSource(playlist);
        // debugPrint("PLAYLIST DATA ====> Conversion to playlist completed. Length: 2");
      }
    } else {
      // debugPrint("PLAYLIST DATA ====> Clearing queue and starting fresh.");
      await _player.stop();
      final playlist = ConcatenatingAudioSource(children: [audioSource]);
      await _player.setAudioSource(playlist);
      // debugPrint("PLAYLIST DATA ====> New playlist created. Length: 1");
    }

    // // debugPrint("PLAYLIST DATA ====> Final Source Type: ${_player.audioSource.runtimeType}");
    // if (_player.audioSource is ConcatenatingAudioSource) {
    //   final playlist = _player.audioSource as ConcatenatingAudioSource;
    // //   debugPrint("PLAYLIST DATA ====> Final Playlist Length: ${playlist.length}");
    // }
    // debugPrint("PLAYLIST DATA ====> addToQueue execution completed.");
  }




  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    await disposePlayer();
    _player = AudioPlayer();

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(mediaItem.id),
        tag: mediaItem,
      ),
    );
  }
}
