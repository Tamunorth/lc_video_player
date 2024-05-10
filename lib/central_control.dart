import 'dart:async';

import 'package:chewie/src/animated_play_pause.dart';
import 'package:chewie/src/center_play_button.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/material/material_progress_bar.dart';
import 'package:chewie/src/material/widgets/options_dialog.dart';
import 'package:chewie/src/material/widgets/playback_speed_dialog.dart';
import 'package:chewie/src/models/option_item.dart';
import 'package:chewie/src/models/subtitle_model.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CenterControlButton extends StatefulWidget {
  const CenterControlButton({
    super.key,
    required this.backgroundColor,
    required this.show,
    required this.isFinished,
    this.onPressed,
    required this.icon,
  });

  final Color backgroundColor;
  final bool show;
  final bool isFinished;

  final Widget icon;

  final VoidCallback? onPressed;

  @override
  State<CenterControlButton> createState() => _CenterControlButtonState();
}

class _CenterControlButtonState extends State<CenterControlButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (pointer) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (pointer) {
        setState(() {
          isHovered = false;
        });
      },
      child: ColoredBox(
        color: Colors.transparent,
        child: Center(
          child: UnconstrainedBox(
            child: AnimatedOpacity(
              opacity: widget.show ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isHovered ? Colors.black : Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: MediaQuery.sizeOf(context).longestSide * 0.08,
                  padding: const EdgeInsets.all(12.0),
                  icon: widget.icon,
                  onPressed: widget.onPressed,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
