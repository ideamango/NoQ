import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
//import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import '../style.dart';
import '../userHomePage.dart';

import 'package:video_player/video_player.dart';

class VideoPlayerApp extends StatefulWidget {
  final String? videoNwLink;
  VideoPlayerApp({Key? key, required this.videoNwLink}) : super(key: key);
  @override
  _VideoPlayerAppState createState() => _VideoPlayerAppState();
}

class _VideoPlayerAppState extends State<VideoPlayerApp> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoNwLink!);

    _controller!.addListener(() {
      setState(() {});
    });
    _controller!.setLooping(true);
    _controller!.initialize().then((_) => setState(() {}));
    _controller!.play();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * .27,
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.fromLTRB(
                8, MediaQuery.of(context).size.height * .05, 8, 8),
            child: MaterialButton(
              padding: EdgeInsets.all(0),
              color: Colors.white,
              splashColor: highlightColor.withOpacity(.8),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserHomePage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    transform: Matrix4.translationValues(5.0, 0, 0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.cyan[400],
                      size: 25,
                      // color: Colors.white38,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    transform: Matrix4.translationValues(-8.0, 0, 0),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey[700],
                      size: 25,
                      // color: Colors.white,
                    ),
                  ),
                  Text(
                    "Back",
                    style: textLabelTextStyle,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller!),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors:
                        VideoProgressColors(playedColor: primaryAccentColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller!.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller!.value.isPlaying ? controller!.pause() : controller!.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller!.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller!.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              // child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
