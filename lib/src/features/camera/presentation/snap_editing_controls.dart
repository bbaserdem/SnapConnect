/// Bottom editing controls for the Snap edit screen.
///
/// Extracted from `snap_edit_screen.dart` to keep the main screen widget small
/// and focused on high-level composition.

import 'package:flutter/material.dart';

import '../../../config/constants.dart';

class SnapEditingControls extends StatelessWidget {
  const SnapEditingControls({
    super.key,
    required this.isPicture,
    required this.snapDuration,
    required this.onSnapDurationChange,
    required this.keepInChat,
    required this.onToggleKeepInChat,
    required this.onEnterTextMode,
    required this.onShowColorPicker,
    required this.onShowSizePicker,
  });

  final bool isPicture;
  final int snapDuration;
  final ValueChanged<int> onSnapDurationChange;
  final bool keepInChat;
  final VoidCallback onToggleKeepInChat;
  final VoidCallback onEnterTextMode;
  final VoidCallback onShowColorPicker;
  final VoidCallback onShowSizePicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPicture) _DurationSlider(snapDuration, onSnapDurationChange),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _EditButton(
                icon: Icons.text_fields,
                label: 'Text',
                onPressed: onEnterTextMode,
              ),
              _EditButton(
                icon: Icons.palette,
                label: 'Color',
                onPressed: onShowColorPicker,
              ),
              _EditButton(
                icon: Icons.format_size,
                label: 'Size',
                onPressed: onShowSizePicker,
              ),
              _EditButton(
                icon: keepInChat ? Icons.all_inclusive : Icons.timer,
                label: keepInChat ? '∞' : '${snapDuration}s',
                onPressed: onToggleKeepInChat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _DurationSlider extends StatelessWidget {
  const _DurationSlider(this.duration, this.onChanged);

  final int duration;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('View for ${duration}s', style: const TextStyle(color: Colors.white)),
          ],
        ),
        Slider(
          value: duration.toDouble(),
          min: AppConstants.minSnapDuration.toDouble(),
          max: AppConstants.maxSnapDuration.toDouble(),
          divisions: AppConstants.maxSnapDuration - AppConstants.minSnapDuration,
          onChanged: (v) => onChanged(v.round()),
          activeColor: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _EditButton extends StatelessWidget {
  const _EditButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
} 