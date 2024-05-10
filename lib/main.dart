import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lc_video_player/animated_cursor.dart';
import 'package:lc_video_player/material_ctrls.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    const VideoPlayerMain(),
  );
}

ValueNotifier<bool> isPlayingVideo = ValueNotifier(false);

class VideoPlayerMain extends StatefulWidget {
  const VideoPlayerMain({
    super.key,
    this.title = 'LC Video Player',
  });

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerMainState();
  }
}

class _VideoPlayerMainState extends State<VideoPlayerMain> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;
  int currPlayIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  List<XFile> srcs = [];

  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.file(File(srcs[currPlayIndex].path));

    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);

    isPlayingVideo.value = true;

    _videoPlayerController1.addListener(() {
      if (_videoPlayerController1.value.isCompleted) {
        toggleVideo();

        // initializePlayer();
      }
    });

    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: false,
      // zoomAndPan: true,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
      // additionalOptions: (context) {
      //   return <OptionItem>[
      //     OptionItem(
      //       onTap: toggleVideo,
      //       iconData: Icons.live_tv_sharp,
      //       title: 'Toggle Video Src',
      //     ),
      //   ];
      // },
      customControls: const MaterialDesktopControlsAlt(),
      hideControlsTimer: const Duration(seconds: 1),
      showControls: true,
      fullScreenByDefault: false,
    );
  }

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= srcs.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  void onPlayListItemTap(int index) {
    currPlayIndex = index;

    initializePlayer();
  }

  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      debugShowCheckedModeBanner: false,
      home: AnimatedCursor(
        child: Scaffold(
          backgroundColor: Colors.black,
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.video_library),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.video,
                allowMultiple: true,
              );

              if (result != null) {
                final files = result.xFiles.map((path) => path!).toList();

                srcs = files;

                print(files.length);

                setState(() {});

                initializePlayer();
              } else {
                print('object');
                // User canceled the picker
              }
            },
          ),
          body: Row(
            children: [
              Expanded(
                child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: isPlayingVideo,
                      builder: (context, isPlayingVideoValue, child) {
                        if (!isPlayingVideoValue) {
                          return _buildDropTarget(context);
                        }

                        return (_chewieController != null &&
                                _chewieController!
                                    .videoPlayerController.value.isInitialized)
                            ? Chewie(
                                controller: _chewieController!,
                              )
                            : _buildDropTarget(context);
                      }),
                ),
              ),
              // Stack(
              //   children: [
              //     _buildDropTarget(context, width: 300, addFiles: true),
              //     Container(
              //       width: 300,
              //       height: MediaQuery.sizeOf(context).height,
              //       decoration: const BoxDecoration(color: Colors.white),
              //       child: ListView(
              //         children: List.generate(
              //           srcs.length,
              //           (index) => ListTile(
              //             title: Text(srcs[index].name),
              //             selected: currPlayIndex == index,
              //             onTap: () {
              //               onPlayListItemTap(index);
              //             },
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  DropTarget _buildDropTarget(BuildContext context,
      {double? width, bool addFiles = false}) {
    return DropTarget(
      onDragDone: (detail) {
        if (!addFiles) {
          srcs = detail.files;

          print(srcs.length);

          initializePlayer();

          return;
        }
        srcs.addAll(detail.files);
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: width ?? MediaQuery.sizeOf(context).width,
        color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
        child: const Center(
          child: Text(
            "Drag and Drop a video here",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
