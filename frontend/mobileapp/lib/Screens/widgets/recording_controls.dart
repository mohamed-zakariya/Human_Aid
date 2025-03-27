import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

class RecordingControls extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onWrongButtonPressed;
  final VoidCallback onRecordButtonPressed;
  final VoidCallback onCorrectButtonPressed;

  const RecordingControls({
    Key? key,
    required this.isRecording,
    required this.isProcessing,
    required this.onWrongButtonPressed,
    required this.onRecordButtonPressed,
    required this.onCorrectButtonPressed,
  }) : super(key: key);

  @override
  State<RecordingControls> createState() => _RecordingControlsState();
}

class _RecordingControlsState extends State<RecordingControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "Cancel" Button
          if (widget.isRecording)
            _ActionButton(
              icon: Icons.cancel_rounded,
              color: Colors.redAccent,
              label: S.of(context).cancel, // <-- Localized
              onPressed:
                  widget.isProcessing ? null : widget.onWrongButtonPressed,
            ),

          const SizedBox(width: 40),

          // Recording Button
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isRecording) _buildWaveAnimation(),
              _RecordButton(
                isRecording: widget.isRecording,
                isProcessing: widget.isProcessing,
                onPressed: widget.onRecordButtonPressed,
              ),
            ],
          ),

          const SizedBox(width: 40),

          // "Confirm" Button
          if (widget.isRecording)
            _ActionButton(
              icon: Icons.check_circle_rounded,
              color: Colors.greenAccent,
              label: S.of(context).confirm, // <-- Localized
              onPressed:
                  widget.isProcessing ? null : widget.onCorrectButtonPressed,
            ),
        ],
      ),
    );
  }

  Widget _buildWaveAnimation() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final adjustedValue = (_waveController.value + index * 0.8) % 1;
            final scale = 1.0 + adjustedValue * 1.2;
            final opacity = 1.0 - adjustedValue;

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity * 0.4,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color.fromARGB(255, 255, 0, 0)
                            .withOpacity(opacity * 1),
                        const Color.fromARGB(255, 255, 0, 0)
                            .withOpacity(opacity * 1),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: onPressed == null ? Colors.grey : color,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: onPressed == null ? Colors.grey : color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final VoidCallback onPressed;

  const _RecordButton({
    required this.isRecording,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isProcessing ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isRecording
                ? [Colors.black, Colors.black]
                : [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? Colors.redAccent : Colors.blueAccent)
                  .withOpacity(1),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isProcessing
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 6,
                )
              : Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  key: ValueKey(isRecording),
                  size: 36,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
