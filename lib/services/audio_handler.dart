// ────────────────────────────────────────────────────────────────────────────
// AudioHandler — just_audio + audio_service integration
// Handles background playback, media notification, and all player controls.
// ────────────────────────────────────────────────────────────────────────────
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MusicAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);

  MusicAudioHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });
    _listenToCurrentIndex();
    _player.setAudioSource(_playlist, preload: false);
  }

  void _listenToCurrentIndex() {
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.isNotEmpty) {
        mediaItem.add(queue.value[index]);
        // Notify via queue
      }
    });
  }

  // ─── Queue management ────────────────────────────────────────────────────
  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final sources = mediaItems.map(_itemToSource).toList();
    await _playlist.addAll(sources);
    queue.add([...queue.value, ...mediaItems]);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
    queue.add([...queue.value, mediaItem]);
  }

  Future<void> setQueueFromItems(List<MediaItem> items, int index) async {
    final sources = items.map(_itemToSource).toList();
    await _playlist.clear();
    await _playlist.addAll(sources);
    queue.add(items);
    await _player.seek(Duration.zero, index: index);
  }

  // ─── Playback controls ───────────────────────────────────────────────────
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.one  => LoopMode.one,
      AudioServiceRepeatMode.all  => LoopMode.all,
      _                           => LoopMode.off,
    };
    await _player.setLoopMode(loopMode);
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  // ─── Internal helpers ────────────────────────────────────────────────────
  AudioSource _itemToSource(MediaItem item) {
    return AudioSource.uri(
      Uri.file(item.extras!['filePath'] as String),
      tag: item,
    );
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final playing = _player.playing;
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToPrevious,
        MediaAction.skipToNext,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (_player.processingState) {
        ProcessingState.idle       => AudioProcessingState.idle,
        ProcessingState.loading    => AudioProcessingState.loading,
        ProcessingState.buffering  => AudioProcessingState.buffering,
        ProcessingState.ready      => AudioProcessingState.ready,
        ProcessingState.completed  => AudioProcessingState.completed,
      },
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  AudioPlayer get player => _player;
}
