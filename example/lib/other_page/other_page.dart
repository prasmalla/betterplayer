import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class OtherPage extends StatefulWidget {
  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    var dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.NETWORK,
      "Default Title",
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      subtitles: BetterPlayerSubtitlesSource.single(
        type: BetterPlayerSubtitlesSourceType.NETWORK,
        url:
            "https://dl.dropboxusercontent.com/s/71nzjo2ux3evxqk/example_subtitles.srt",
      ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        controlsConfiguration:
            BetterPlayerControlsConfiguration(enableProgressText: true),
      ),
    );
    _betterPlayerController.addEventsListener((event) {
      print("Better player event: ${event.betterPlayerEventType}");
    });
    _betterPlayerController.setupDataSource(dataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Other page"),
      ),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer.network(
          "Default Title",
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
          betterPlayerConfiguration: BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }
}
