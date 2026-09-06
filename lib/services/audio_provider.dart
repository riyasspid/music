// ────────────────────────────────────────────────────────────────────────────
// AudioProvider — GetX controller for all player state
// ────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/song.dart';
import '../data/repositories/song_repository.dart';
import 'audio_handler.dart';

class AudioProvider extends GetxController {
  final MusicAudioHandler _handler;
  final SongRepository _songRepo;

  AudioProvider(this._handler, this._songRepo);

  // ─── Observable state ──────────────────────────────────────────────────
  final Rx<Song?> currentSong = Rx<Song?>(null);
  final RxList<Song> queue = <Song>[].obs;
  final RxBool isPlaying = false.obs;
  final RxBool isShuffle = false.obs;
  final Rx<LoopMode> loopMode = LoopMode.off.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxInt currentIndex = 0.obs;

  // For play count: track seconds listened per song
  int _secondsListened = 0;
  String? _lastSongId;
  Timer? _listenTimer;

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
  }

  void _bindStreams() {
    // Playing state
    _handler.player.playingStream.listen((playing) {
      isPlaying.value = playing;
      if (playing) {
        _startListenTimer();
      } else {
        _stopListenTimer();
      }
    });

    // Position
    _handler.player.positionStream.listen((pos) {
      position.value = pos;
    });

    // Duration
    _handler.player.durationStream.listen((dur) {
      if (dur != null) duration.value = dur;
    });

    // Current index → update currentSong
    _handler.player.currentIndexStream.listen((index) {
      if (index != null && queue.isNotEmpty && index < queue.length) {
        currentIndex.value = index;
        currentSong.value = queue[index];
        _checkSongChange();
      }
    });

    // Shuffle
    _handler.player.shuffleModeEnabledStream.listen((v) {
      isShuffle.value = v;
    });

    // Loop
    _handler.player.loopModeStream.listen((mode) {
      loopMode.value = mode;
    });
  }

  // ─── Play count tracking ─────────────────────────────────────────────────
  void _checkSongChange() {
    final id = currentSong.value?.id;
    if (id != _lastSongId) {
      _secondsListened = 0;
      _lastSongId = id;
    }
  }

  void _startListenTimer() {
    _listenTimer?.cancel();
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsListened++;
      // Increment play count after 30 seconds of continuous listening
      if (_secondsListened == 30 && currentSong.value != null) {
        _songRepo.incrementPlayCount(currentSong.value!.id);
      }
    });
  }

  void _stopListenTimer() {
    _listenTimer?.cancel();
  }

  // ─── Public controls ─────────────────────────────────────────────────────
  Future<void> playSong(Song song, {List<Song>? songList}) async {
    final list = songList ?? [song];
    final index = list.indexWhere((s) => s.id == song.id);
    queue.assignAll(list);
    currentSong.value = song;
    currentIndex.value = index < 0 ? 0 : index;

    final items = list.map(_songToMediaItem).toList();
    await _handler.setQueueFromItems(items, currentIndex.value);
    await _handler.play();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> next() => _handler.skipToNext();
  Future<void> previous() => _handler.skipToPrevious();
  Future<void> skipToIndex(int index) => _handler.skipToQueueItem(index);

  Future<void> seekTo(Duration position) => _handler.seek(position);

  Future<void> seekRelative(Duration offset) {
    final currentMs = position.value.inMilliseconds;
    final offsetMs = offset.inMilliseconds;
    final durationMs = duration.value.inMilliseconds;
    final newMs = (currentMs + offsetMs).clamp(0, durationMs);
    return _handler.seek(Duration(milliseconds: newMs));
  }

  Future<void> toggleShuffle() async {
    final next = !isShuffle.value;
    await _handler.setShuffleMode(
      next ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  Future<void> cycleLoopMode() async {
    final AudioServiceRepeatMode next;
    switch (loopMode.value) {
      case LoopMode.off:
        next = AudioServiceRepeatMode.all;
        break;
      case LoopMode.all:
        next = AudioServiceRepeatMode.one;
        break;
      case LoopMode.one:
        next = AudioServiceRepeatMode.none;
        break;
    }
    await _handler.setRepeatMode(next);
  }

  Future<void> addToQueue(Song song) async {
    queue.add(song);
    await _handler.addQueueItem(_songToMediaItem(song));
  }

  Future<void> toggleLike(Song song) async {
    await _songRepo.toggleLike(song.id);
    // Refresh if it's the current song
    if (currentSong.value?.id == song.id) {
      currentSong.value = _songRepo.getById(song.id);
    }
  }

  Future<void> stop() => _handler.stop();

  MediaItem _songToMediaItem(Song song) => MediaItem(
        id: song.id,
        title: song.title,
        artist: song.author,
        duration: Duration(seconds: song.seconds),
        artUri: song.coverPath != null ? Uri.file(song.coverPath!) : null,
        extras: {'filePath': song.filePath},
      );

  @override
  void onClose() {
    _listenTimer?.cancel();
    super.onClose();
  }
}
