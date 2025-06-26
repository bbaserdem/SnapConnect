/// Debug information banner to show app status during development.
/// 
/// This widget displays network connectivity, Firebase status, and other debug info
/// to help troubleshoot issues during development.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Debug info banner that shows app status
class DebugInfoBanner extends ConsumerStatefulWidget {
  const DebugInfoBanner({super.key});

  @override
  ConsumerState<DebugInfoBanner> createState() => _DebugInfoBannerState();
}

class _DebugInfoBannerState extends ConsumerState<DebugInfoBanner> {
  List<ConnectivityResult>? _connectivityResult;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (mounted) {
        setState(() {
          _connectivityResult = result;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _connectivityResult = result;
      });
    }
  }

  String _getConnectivityString() {
    if (_connectivityResult == null) return 'Checking...';
    if (_connectivityResult!.contains(ConnectivityResult.none)) return 'No Connection';
    if (_connectivityResult!.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (_connectivityResult!.contains(ConnectivityResult.mobile)) return 'Mobile';
    if (_connectivityResult!.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    return 'Connected';
  }

  Color _getStatusColor() {
    if (_connectivityResult == null) return Colors.orange;
    if (_connectivityResult!.contains(ConnectivityResult.none)) return Colors.red;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (kReleaseMode) return const SizedBox.shrink();

    return Material(
      elevation: 2,
      color: Colors.black87,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isExpanded ? 120 : 30,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Debug: ${_getConnectivityString()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Network', _getConnectivityString(), _getStatusColor()),
                      const SizedBox(height: 4),
                      _buildInfoRow('Platform', defaultTargetPlatform.name, Colors.blue),
                      const SizedBox(height: 4),
                      _buildInfoRow('Mode', kDebugMode ? 'Debug' : 'Release', Colors.blue),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to collapse',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
} 