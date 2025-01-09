import 'package:audio_service/audio_service.dart';
import 'package:city_sightseeing/main.dart';
import 'package:city_sightseeing/strings.dart';
import 'package:city_sightseeing/widgets/audio_handler.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import 'audio_map_service.dart';

class PlayAudioService extends ChangeNotifier {
  bool _playerStatePlayingSample = false;

  bool get playerStatePlayingSample => _playerStatePlayingSample;

  bool _playerStatePlaying = false;

  bool get playerStatePlaying => _playerStatePlaying;

  Duration? _position;

  Duration? get position => _position;

  Duration? _duration;

  Duration? get duration => _duration;

  AudioPlayer _player = audioHandler.player;

  // AudioPlayer get player => _player;

  late AudioMapService _audioMapService;

  PlayAudioService(BuildContext context) {
    _audioMapService = Provider.of<AudioMapService>(context, listen: false);
    // initializePlayerComponents();

    // playlist = ConcatenatingAudioSource(
    //   children: [
    //     AudioSource.uri(
    //       Uri.parse(
    //           "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
    //       tag: MediaItem(id: "1", title: "audio-demo-1"),
    //     ),
    //     AudioSource.uri(
    //       Uri.parse(
    //           "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3"),
    //       tag: MediaItem(id: "2", title: "audio-demo-2"),
    //     ),
    //     AudioSource.uri(
    //       Uri.parse(
    //           "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"),
    //       tag: MediaItem(id: "3", title: "audio-demo-3"),
    //     )
    //   ],
    // );
    // setPlayerListSource();
  }

  Future<void> initializePlayerComponents() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // debugPrint("initializePlayerComponents");
  }

  void setSeekPosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  void setDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  ///TODO Here are some @demoPurpose code
  Future<void> setPlayerSource(
    String source,
    String page, {
      String? isInQueue,
    required MediaItem tag,
  }) async {
    bool clearQueue = false;
    // _player.setReleaseMode(ReleaseMode.stop);
    if (_playerStatePlayingSample) {
      await stopAudio(ConstantStrings.sampleAudioPage);

    }
   //todo - check
    if (_playerStatePlaying && page == ConstantStrings.sampleAudioPage) {
      await stopAudio(ConstantStrings.triggerPointPage);
    }

    // debugPrint("current uri :- ${_player.sequenceState?.currentSource}");
    // debugPrint("total songs :- ${_player.sequence?.length}");

    addDataToLog("total songs :- ${_player.sequence?.length}");
    await audioHandler.addToQueue(tag,isInQueue: isInQueue==null ? false :(isInQueue=="yes"? true: false), clearQueue: clearQueue);

    ///ensure that the player doesn't restart an already playing audio item, and instead either resumes playback or logs that the audio is already playing.
    if (_player.sequenceState?.currentSource?.tag != null) {

      if (_player.sequenceState?.currentSource?.tag is MediaItem) {
        final currentMediaItem =
            _player.sequenceState?.currentSource?.tag as MediaItem;
        if (currentMediaItem.id == tag.id) {
          if (_player.playing) {
            addDataToLog(" Already Playing");
            // debugPrint("PLAYLIST DATA ====> Already Playing");
            return;
          } else {
            _player.play();  //todo
            addDataToLog("Resume");
            // debugPrint("PLAYLIST DATA ====> Resume");
          }
        }
      }
    }
    // debugPrint("bottom");
    // final audioSource = AudioSource.uri(
    //   Uri.parse(source),
    //   tag: tag,
    // );

    if (page == ConstantStrings.triggerPointPage) {}

    addDataToLog("Reached in the setPlayerSource ${tag.id}||${tag.title}");
    // await audioHandler.updateMediaItem(tag);
    _player = audioHandler.player;
    setPlayerState(page, true);
    playAudio(page);
    addDataToLog("Reached in the player source in Down Before play");
    await audioHandler.play();
    addDataToLog(
      "Reached in the player source in Down After play ${_player.playing}",
      end: true,
    );
  }

  Future<void> playAudio(String page) async {
    // await _player.resume();
    setDuration(_player.duration ?? Duration());
    _player.positionStream.listen((position) {
      setSeekPosition(_player.position);
    });
    _player.playerStateStream.listen((state) {
      setPlayerState(page, state.playing);
      if (state.processingState == ProcessingState.completed) {
        setPlayerState(page, false);
      }
    });
    // _player.onPlayerComplete.listen((event) {
    //   setPlayerState(page, false);
    // });
  }

  Future<void> pauseAudio(String page) async {
    if (!_player.playing) return;
    await audioHandler.pause();
    setPlayerState(page, false);
  }

  Future<void> stopAudio(String page) async {
    if (!_player.playing) return;
    await audioHandler.stop();
    // debugPrint("Audio stopped");
    setPlayerState(page, false);
  }

  Future<void> releasePlayer(String page, BuildContext context) async {
    await audioHandler.stop();
    // await _player.();

    setPlayerState(ConstantStrings.triggerPointPage, false);
    setPlayerState(ConstantStrings.sampleAudioPage, false);
    notifyListeners();
  }

  void setPlayerState(String page, bool state) {
    if (page == ConstantStrings.triggerPointPage) {
      _playerStatePlaying = state;
      _audioMapService.setAudioListState(state);
    } else {
      _playerStatePlayingSample = state;
    }
    notifyListeners();
  }

  @override
  void dispose() async {
    await _player.stop();
    super.dispose();
  }
}
