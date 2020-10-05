import 'package:better_player/better_player.dart';
import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:better_player/src/hls/better_player_hls_track.dart';
import 'package:better_player/src/video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fling/flutter_fling.dart';
import 'package:flutter_fling/remote_media_player.dart';
import 'package:flutter/services.dart' show PlatformException;

///Base class for both material and cupertino controls
abstract class BetterPlayerControlsState<T extends StatefulWidget>
    extends State<T> {
  List<RemoteMediaPlayer> _flingDevices;
  RemoteMediaPlayer _selectedPlayer;
  FlutterFling fling;

  getCastDevices() async {
    await FlutterFling.startDiscoveryController((status, player) {
      _flingDevices = List();
      if (status == PlayerDiscoveryStatus.Found) {
        setState(() {
          _flingDevices.add(player);
        });
      } else {
        setState(() {
          _flingDevices.remove(player);
        });
      }
    });
  }

  getSelectedDevice() async {
    RemoteMediaPlayer selectedDevice;
    try {
      selectedDevice = await FlutterFling.selectedPlayer;
    } on PlatformException {
      print('Failed to get selected device');
    }
    setState(() {
      _selectedPlayer = selectedDevice;
    });
  }

  castMediaTo(RemoteMediaPlayer player) async {
    _selectedPlayer = player;
    await FlutterFling.play((state, condition, position) {},
            player: _selectedPlayer,
            mediaUri:
                await getBetterPlayerController().betterPlayerDataSource.url,
            mediaTitle:
                await getBetterPlayerController().betterPlayerDataSource.title)
        .then((_) => getSelectedDevice());
  }

  void _cast() async {
    fling = FlutterFling();
    await getSelectedDevice();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _flingDevices == null
                    ? const Text(
                        'Search to begin then tap on device name to cast')
                    : _flingDevices.isEmpty
                        ? const Text('None nearby')
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _flingDevices.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_flingDevices[index].name),
                                subtitle: Text(_flingDevices[index].uid),
                                onTap: () => castMediaTo(_flingDevices[index]),
                              );
                            },
                          ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // RaisedButton(
                    //   child: Text('Search'),
                    //   onPressed: () => await getCastDevices(),
                    // ),
                    // RaisedButton(
                    //   child: Text('Dispose Controller'),
                    //   onPressed: () async {
                    //     await FlutterFling.stopDiscoveryController();
                    //     setState(() {
                    //       _flingDevices = List();
                    //       _selectedPlayer = null;
                    //     });
                    //   },
                    // ),
                    Row(
                      children: [
                        FlatButton(
                          child: const Icon(Icons.fast_rewind),
                          onPressed: () async =>
                              await FlutterFling.seekBackPlayer(),
                        ),
                        FlatButton(
                          child: const Icon(Icons.play_arrow),
                          onPressed: () async =>
                              await FlutterFling.playPlayer(),
                        ),
                        FlatButton(
                          child: const Icon(Icons.fast_forward),
                          onPressed: () async =>
                              await FlutterFling.seekForwardPlayer(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        FlatButton(
                          child: const Icon(Icons.volume_mute),
                          onPressed: () async =>
                              await FlutterFling.mutePlayer(true),
                        ),
                        FlatButton(
                          child: const Icon(Icons.pause),
                          onPressed: () async =>
                              await FlutterFling.pausePlayer(),
                        ),
                        FlatButton(
                          child: const Icon(Icons.stop),
                          onPressed: () async {
                            await FlutterFling.stopPlayer();
                            setState(() {
                              // keep device until disposed
                              // _flingDevices = null;
                            });
                          },
                        ),
                        FlatButton(
                          child: const Icon(Icons.volume_up),
                          onPressed: () async =>
                              await FlutterFling.mutePlayer(false),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ///Min. time of buffered video to hide loading timer (in milliseconds)
  static const int _bufferingInterval = 20000;

  BetterPlayerController getBetterPlayerController();

  void onShowMoreClicked() async {
    await getCastDevices(); // start discovery on load

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: _buildMoreOptionsList(),
        );
      },
    );
  }

  Widget _buildMoreOptionsList() {
    var controlsConfiguration = getBetterPlayerController()
        .betterPlayerConfiguration
        .controlsConfiguration;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            if (controlsConfiguration.enablePlaybackSpeed)
              _buildMoreOptionsListRow(Icons.shutter_speed, "Playback speed",
                  () {
                Navigator.of(context).pop();
                _showSpeedChooserWidget();
              }),
            if (controlsConfiguration.enableSubtitles)
              _buildMoreOptionsListRow(Icons.text_fields, "Subtitles", () {
                Navigator.of(context).pop();
                _showSubtitlesSelectionWidget();
              }),
            if (controlsConfiguration.enableQualities)
              _buildMoreOptionsListRow(Icons.cast, "Cast", () {
                Navigator.of(context).pop();
                // _showQualitiesSelectionWidget();
                _cast();
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsListRow(IconData icon, String name, Function onTap) {
    assert(icon != null, "Icon can't be null");
    assert(name != null, "Name can't be null");
    assert(onTap != null, "OnTap can't be null");
    return BetterPlayerMaterialClickableWidget(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Text(name),
          ],
        ),
      ),
    );
  }

  void _showSpeedChooserWidget() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSpeedRow(0.25),
                  _buildSpeedRow(0.5),
                  _buildSpeedRow(0.75),
                  _buildSpeedRow(1.0),
                  _buildSpeedRow(1.25),
                  _buildSpeedRow(1.5),
                  _buildSpeedRow(1.75),
                  _buildSpeedRow(2.0),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSpeedRow(double value) {
    assert(value != null, "Value can't be null");
    return BetterPlayerMaterialClickableWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              "$value x",
              style: TextStyle(
                  fontWeight: getBetterPlayerController()
                              .videoPlayerController
                              .value
                              .speed ==
                          value
                      ? FontWeight.bold
                      : FontWeight.normal),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        getBetterPlayerController().setSpeed(value);
      },
    );
  }

  bool isLoading(VideoPlayerValue latestValue) {
    assert(latestValue != null, "Latest value can't be null");
    if (latestValue != null) {
      if (!latestValue.isPlaying && latestValue.duration == null) {
        return true;
      }

      Duration position = latestValue.position;

      Duration bufferedEndPosition;
      if (latestValue.buffered?.isNotEmpty == true) {
        bufferedEndPosition = latestValue.buffered.last.end;
      }

      if (position != null && bufferedEndPosition != null) {
        var difference = bufferedEndPosition - position;

        if (latestValue.isPlaying &&
            latestValue.isBuffering &&
            difference.inMilliseconds < _bufferingInterval) {
          return true;
        }
      }
    }
    return false;
  }

  void _showSubtitlesSelectionWidget() {
    var subtitles =
        List.of(getBetterPlayerController().betterPlayerSubtitlesSourceList);
    var noneSubtitlesElementExists = subtitles?.firstWhere(
            (source) => source.type == BetterPlayerSubtitlesSourceType.NONE,
            orElse: () => null) !=
        null;
    if (!noneSubtitlesElementExists) {
      subtitles?.add(BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.NONE));
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              children: subtitles
                  .map((source) => _buildSubtitlesSourceRow(source))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitlesSourceRow(BetterPlayerSubtitlesSource subtitlesSource) {
    assert(subtitlesSource != null, "SubtitleSource can't be null");

    var selectedSourceType =
        getBetterPlayerController().betterPlayerSubtitlesSource;
    bool isSelected = (subtitlesSource == selectedSourceType) ||
        (subtitlesSource.type == BetterPlayerSubtitlesSourceType.NONE &&
            subtitlesSource?.type == selectedSourceType.type);

    return BetterPlayerMaterialClickableWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              subtitlesSource.type == BetterPlayerSubtitlesSourceType.NONE
                  ? "None"
                  : subtitlesSource.name ?? "Default subtitles",
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        getBetterPlayerController().setupSubtitleSource(subtitlesSource);
      },
    );
  }

  ///Build both track and resolution selection
  ///Track selection is used for HLS videos
  ///Resolution selection is used for normal videos
  void _showQualitiesSelectionWidget() {
    List<String> trackNames =
        getBetterPlayerController().betterPlayerDataSource.hlsTrackNames ??
            List();
    List<BetterPlayerHlsTrack> tracks =
        getBetterPlayerController().betterPlayerTracks;
    var children = List<Widget>();
    for (var index = 0; index < tracks.length; index++) {
      var preferredName = trackNames.length > index ? trackNames[index] : null;
      children.add(_buildTrackRow(tracks[index], preferredName));
    }
    var resolutions =
        getBetterPlayerController().betterPlayerDataSource.resolutions;
    resolutions?.forEach((key, value) {
      children.add(_buildResolutionSelectionRow(key, value));
    });

    if (children.isEmpty) {
      children.add(_buildTrackRow(BetterPlayerHlsTrack(0, 0, 0), "Default"));
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              children: children,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackRow(BetterPlayerHlsTrack track, String preferredName) {
    assert(track != null, "Track can't be null");

    String trackName = preferredName ??
        track.width.toString() +
            "x" +
            track.height.toString() +
            " " +
            BetterPlayerUtils.formatBitrate(track.bitrate);

    var selectedTrack = getBetterPlayerController().betterPlayerTrack;
    bool isSelected = selectedTrack != null && selectedTrack == track;

    return BetterPlayerMaterialClickableWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              "$trackName",
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        getBetterPlayerController().setTrack(track);
      },
    );
  }

  Widget _buildResolutionSelectionRow(String name, String url) {
    bool isSelected =
        url == getBetterPlayerController().betterPlayerDataSource.url;
    return BetterPlayerMaterialClickableWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              "$name",
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        getBetterPlayerController().setResolution(url);
      },
    );
  }
}
