import 'package:better_player/src/configuration/better_player_data_source_type.dart';
import 'package:better_player/src/subtitles/better_player_subtitles_source.dart';

class BetterPlayerDataSource {
  ///Type of source of video
  final BetterPlayerDataSourceType type;

  ///Title of the video
  final String title;

  ///Url of the video
  final String url;

  ///Subtitles configuration
  final List<BetterPlayerSubtitlesSource> subtitles;

  ///Flag to determine if current data source is live stream
  final bool liveStream;

  /// Custom headers for player
  final Map<String, String> headers;

  ///Should player use hls subtitles
  final bool useHlsSubtitles;

  ///Should player use hls tracks
  final bool useHlsTracks;

  ///List of strings that represents tracks names.
  ///If empty, then better player will choose name based on track parameters
  final List<String> hlsTrackNames;

  ///Optional, alternative resolutions for non-hls video. Used to setup
  ///different qualities for video.
  ///Data should be in given format:
  ///{"360p": "url", "540p": "url2" }
  final Map<String, String> resolutions;

  BetterPlayerDataSource(
    this.type,
    this.title,
    this.url, {
    this.subtitles,
    this.liveStream = false,
    this.headers,
    this.useHlsSubtitles = true,
    this.useHlsTracks = true,
    this.hlsTrackNames,
    this.resolutions,
  });

  @override
  String toString() {
    return 'BetterPlayerDataSource{type: $type, title: $title, url: $url, subtitles: $subtitles,'
        ' liveStream: $liveStream, headers: $headers, useHlsSubtitles: $useHlsSubtitles}';
  }

  BetterPlayerDataSource copyWith(
      {BetterPlayerDataSourceType type,
      String title,
      String url,
      List<BetterPlayerSubtitlesSource> subtitles,
      bool liveStream,
      Map<String, String> headers,
      bool useHlsSubtitles,
      bool useHlsTracks,
      Map<String, String> qualities}) {
    return BetterPlayerDataSource(
      type ?? this.type,
      title ?? this.title,
      url ?? this.url,
      subtitles: subtitles ?? this.subtitles,
      liveStream: liveStream ?? this.liveStream,
      headers: headers ?? this.headers,
      useHlsSubtitles: useHlsSubtitles ?? this.useHlsSubtitles,
      useHlsTracks: useHlsTracks ?? this.useHlsTracks,
      resolutions: qualities ?? this.resolutions,
    );
  }
}
