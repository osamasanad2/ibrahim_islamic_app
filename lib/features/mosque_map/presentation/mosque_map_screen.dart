import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/providers.dart';

class MosqueMapScreen extends ConsumerStatefulWidget {
  const MosqueMapScreen({super.key});

  @override
  ConsumerState<MosqueMapScreen> createState() => _MosqueMapScreenState();
}

class _MosqueMapScreenState extends ConsumerState<MosqueMapScreen> {
  LatLng? _currentPosition;
  bool _loading = true;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final location = await ref.read(locationServiceProvider).getCurrentLocation();
      final position = LatLng(location.latitude, location.longitude);
      setState(() {
        _currentPosition = position;
        _loading = false;
      });
      _fetchNearbyMosques(position);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchNearbyMosques(LatLng position) async {
    try {
      final dio = ref.read(dioProvider);
      final query = '''
        [out:json];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:5000,${position.latitude},${position.longitude});
          way["amenity"="place_of_worship"]["religion"="muslim"](around:5000,${position.latitude},${position.longitude});
        );
        out center;
      ''';

      final response = await dio.post(
        'https://overpass-api.de/api/interpreter',
        data: query,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      if (response.data != null && response.data['elements'] != null) {
        final elements = response.data['elements'] as List;
        final Set<Marker> newMarkers = {};
        
        for (var element in elements) {
          final lat = element['type'] == 'node' ? element['lat'] : element['center']['lat'];
          final lon = element['type'] == 'node' ? element['lon'] : element['center']['lon'];
          final tags = element['tags'] ?? {};
          final name = tags['name:ar'] ?? tags['name'] ?? 'مسجد';

          newMarkers.add(Marker(
            markerId: MarkerId(element['id'].toString()),
            position: LatLng(lat, lon),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ));
        }

        if (mounted) {
          setState(() {
            _markers = newMarkers;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching mosques: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('المساجد القريبة'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _currentPosition == null
              ? const Center(
                  child: Text('تعذر تحديد موقعك، يرجى تفعيل الـ GPS', style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18)),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      mapType: MapType.normal,
                      markers: _markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      style: _mapStyle(),
                    ),
                    if (_markers.isEmpty)
                      Positioned(
                        top: 16, left: 16, right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.goldMuted),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('جاري البحث عن المساجد القريبة...', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  String? _mapStyle() {
    return '''[
      {
        "elementType": "geometry",
        "stylers": [
          {"color": "#0F1C3A"}
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#C9A84C"}
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#0F1C3A"}
        ]
      }
    ]''';
  }
}

// Add route in app_router.dart:
// GoRoute(path: '/mosque-map', builder: (context, state) => const MosqueMapScreen()),
