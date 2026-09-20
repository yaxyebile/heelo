import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveTrackingView extends StatefulWidget {
  final String orderId;
  final bool isDriver;

  const LiveTrackingView({
    super.key,
    required this.orderId,
    this.isDriver = false,
  });

  @override
  State<LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  final MapController _mapController = MapController();
  // Default fallback: Mogadishu center
  LatLng _currentLocation = const LatLng(2.0469, 45.3182);
  bool _hasReceivedDriverPos = false;
  RealtimeChannel? _channel;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    try {
      // 1. Try to get current GPS position if available
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null && mounted) {
          setState(() {
            _currentLocation = LatLng(lastPos.latitude, lastPos.longitude);
            if (widget.isDriver) _hasReceivedDriverPos = true;
          });
        }
      } catch (_) {}

      if (widget.isDriver) {
        // Handle permissions for Driver
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            final currentPos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
            ).timeout(const Duration(seconds: 5), onTimeout: () async {
              return Position(
                longitude: 45.3182,
                latitude: 2.0469,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                altitudeAccuracy: 0,
                heading: 0,
                headingAccuracy: 0,
                speed: 0,
                speedAccuracy: 0,
              );
            });
            if (mounted) {
              setState(() {
                _currentLocation = LatLng(currentPos.latitude, currentPos.longitude);
                _hasReceivedDriverPos = true;
              });
            }
          }
        }
      }

      // 2. Setup Supabase Realtime Channel
      final client = Supabase.instance.client;
      _channel = client.channel('tracking_${widget.orderId}');

      if (widget.isDriver) {
        _channel?.subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            _positionStream = Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5,
              ),
            ).listen((Position position) {
              final loc = LatLng(position.latitude, position.longitude);
              if (mounted) {
                setState(() {
                  _currentLocation = loc;
                  _hasReceivedDriverPos = true;
                });
                try {
                  _mapController.move(loc, 15.0);
                } catch (_) {}
              }
              _channel?.sendBroadcastMessage(
                event: 'location',
                payload: {'lat': position.latitude, 'lng': position.longitude},
              );
            });
          }
        });
      } else {
        // Customer receiving driver position
        _channel?.onBroadcast(
          event: 'location',
          callback: (payload) {
            final lat = (payload['lat'] as num).toDouble();
            final lng = (payload['lng'] as num).toDouble();
            final loc = LatLng(lat, lng);
            if (mounted) {
              setState(() {
                _currentLocation = loc;
                _hasReceivedDriverPos = true;
              });
              try {
                _mapController.move(loc, 15.0);
              } catch (_) {}
            }
          },
        ).subscribe();
      }
    } catch (e) {
      debugPrint('LiveTracking init error: $e');
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    if (_channel != null) {
      try {
        Supabase.instance.client.removeChannel(_channel!);
      } catch (_) {}
    }
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Live Tracking (Raad-raac)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mogadishu.market',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 50,
                    height: 50,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status Overlay Banner
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _hasReceivedDriverPos
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : const Color(0xFFFF6B00).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _hasReceivedDriverPos ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                      color: _hasReceivedDriverPos ? const Color(0xFF10B981) : const Color(0xFFFF6B00),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.isDriver
                              ? "Live GPS Broadcast Active 📡"
                              : (_hasReceivedDriverPos
                                  ? "Wadaha waa la raad-raacayaa 🛵"
                                  : "Wadaha ayaan la sugaa (Live GPS)"),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isDriver
                              ? "Location-kaaga toos ayaa loogu muujinayaa macmiilka."
                              : (_hasReceivedDriverPos
                                  ? "Waduhu wuu ku soo socdaa. Location-kiisa toos ayaad u aragtaa."
                                  : "Marka waduhu moobaylka ka shido GPS-ka, toos ayaa halkan maabka loogu dul arki doonaa."),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Re-center button
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _mapController.move(_currentLocation, 16.0),
              backgroundColor: const Color(0xFF4F46E5),
              child: const Icon(Icons.my_location_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
