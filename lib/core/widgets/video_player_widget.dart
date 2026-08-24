import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  YoutubePlayerController? _ytController;
  VideoPlayerController? _videoController;
  bool _isYoutube = false;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final videoId = YoutubePlayerController.convertUrlToId(widget.url);
    if (videoId != null && videoId.isNotEmpty) {
      _isYoutube = true;
      _ytController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
        ),
      );
      setState(() => _isLoading = false);
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() => _isLoading = false);
        }).catchError((e) {
          setState(() => _isLoading = false);
        });
    }
  }

  @override
  void dispose() {
    _ytController?.close();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_isYoutube && _ytController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: YoutubePlayer(
          controller: _ytController!,
          aspectRatio: 16 / 9,
        ),
      );
    }

    if (_videoController != null && _videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_videoController!),
              _ControlsOverlay(controller: _videoController!),
              VideoProgressIndicator(_videoController!, allowScrubbing: true),
            ],
          ),
        ),
      );
    }

    return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
            child: Text("Muuqaalka lama furi karo",
                style: TextStyle(color: Colors.white))));
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;

  const _ControlsOverlay({required this.controller});

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller.value.isPlaying
            ? widget.controller.pause()
            : widget.controller.play();
        setState(() {});
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: widget.controller.value.isPlaying
              ? const SizedBox.shrink()
              : const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 64,
                ),
        ),
      ),
    );
  }
}
