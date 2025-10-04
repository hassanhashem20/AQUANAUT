import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoExample extends StatefulWidget {
  @override
  _YoutubeVideoExampleState createState() => _YoutubeVideoExampleState();
}

class _YoutubeVideoExampleState extends State<YoutubeVideoExample> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'xxBf1pspDGE', // Replace with your YouTube video ID
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YouTube Player Example")),
      body: Center(
        child: YoutubePlayerScaffold(
          controller: _controller,
          builder: (context, player) {
            return AspectRatio(aspectRatio: 16 / 9, child: player);
          },
        ),
      ),
    );
  }
}
