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
  LatLng? _currentLocation;
  late RealtimeChannel _channel;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    // 1. Request location permissions if driver
    if (widget.isDriver) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
    }

    // 2. Setup Supabase Channel
    _channel = Supabase.instance.client.channel('tracking_${widget.orderId}');

    if (widget.isDriver) {
      // Driver sending location
      _channel.subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _positionStream = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position position) {
            final loc = LatLng(position.latitude, position.longitude);
            if (mounted) {
              setState(() => _currentLocation = loc);
              _mapController.move(loc, 15.0);
            }
            _channel.sendBroadcastMessage(
              event: 'location',
              payload: {'lat': position.latitude, 'lng': position.longitude},
            );
          });
        }
      });
    } else {
      // Customer receiving location
      _channel.onBroadcast(
        event: 'location',
        callback: (payload) {
          final lat = payload['lat'] as double;
          final lng = payload['lng'] as double;
          final loc = LatLng(lat, lng);
          if (mounted) {
            setState(() => _currentLocation = loc);
            _mapController.move(loc, 15.0);
          }
        },
      ).subscribe();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    Supabase.instance.client.removeChannel(_channel);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking 🛵"),
        centerTitle: true,
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
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
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.motorcycle, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
