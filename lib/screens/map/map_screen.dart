import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/destination_model.dart';
import '../../providers/destination_provider.dart';
import '../explorer/destination_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 5.5;

  // Simulated user location (Hanoi center)
  final LatLng _userLocation = const LatLng(21.0285, 105.8542);

  Destination? _selectedDestination;
  List<LatLng> _routePoints = [];
  bool _isShowingRoute = false;

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _moveToVietnam() {
    setState(() {
      _currentZoom = 5.5;
      _routePoints = [];
      _isShowingRoute = false;
      _selectedDestination = null;
    });
    _mapController.move(const LatLng(16.0, 106.0), 5.5);
  }

  void _showRoute(Destination dest) {
    setState(() {
      _selectedDestination = dest;
      _isShowingRoute = true;
      // Simulate a basic route with a few waypoints between user and destination
      _routePoints = _buildSimulatedRoute(
        _userLocation,
        LatLng(dest.latitude, dest.longitude),
      );
    });
    _mapController.move(
      LatLng(
        (_userLocation.latitude + dest.latitude) / 2,
        (_userLocation.longitude + dest.longitude) / 2,
      ),
      5.0,
    );
  }

  List<LatLng> _buildSimulatedRoute(LatLng from, LatLng to) {
    // Create intermediate waypoints for a more realistic-looking route
    final midLat1 = from.latitude + (to.latitude - from.latitude) * 0.25;
    final midLng1 = from.longitude + (to.longitude - from.longitude) * 0.3;
    final midLat2 = from.latitude + (to.latitude - from.latitude) * 0.6;
    final midLng2 = from.longitude + (to.longitude - from.longitude) * 0.55;
    final midLat3 = from.latitude + (to.latitude - from.latitude) * 0.85;
    final midLng3 = from.longitude + (to.longitude - from.longitude) * 0.8;

    return [
      from,
      LatLng(midLat1, midLng1),
      LatLng(midLat2, midLng2),
      LatLng(midLat3, midLng3),
      to,
    ];
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _isShowingRoute = false;
      _selectedDestination = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DestinationProvider>(context);

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(16.0, 106.0),
                    initialZoom: _currentZoom,
                    onMapEvent: (event) {
                      if (event is MapEventMove) {
                        setState(() {
                          _currentZoom = event.camera.zoom;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.wanderlab',
                    ),

                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),

                    // User location marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLocation,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Destination markers
                    MarkerLayer(
                      markers: provider.destinations.map((dest) {
                        final isSelected = _selectedDestination?.id == dest.id;
                        return Marker(
                          point: LatLng(dest.latitude, dest.longitude),
                          width: isSelected ? 70 : 50,
                          height: isSelected ? 70 : 50,
                          child: GestureDetector(
                            onTap: () => _showDestinationBottomSheet(dest),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue : Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    dest.name.split(' ').first,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: isSelected ? Colors.blue : Colors.red,
                                  size: isSelected ? 32 : 26,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Route info banner
                if (_isShowingRoute && _selectedDestination != null)
                  Positioned(
                    top: 50,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions, color: Colors.blue, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chỉ đường đến: ${_selectedDestination!.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Từ: Hà Nội (vị trí hiện tại)',
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _clearRoute,
                            icon: const Icon(Icons.close, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Zoom controls + locate me button
                Positioned(
                  right: 16,
                  bottom: 120,
                  child: Column(
                    children: [
                      _MapButton(icon: Icons.add, onTap: _zoomIn),
                      const SizedBox(height: 8),
                      _MapButton(icon: Icons.remove, onTap: _zoomOut),
                      const SizedBox(height: 16),
                      _MapButton(icon: Icons.explore, onTap: _moveToVietnam, color: Colors.blue),
                    ],
                  ),
                ),

                // Zoom level indicator
                Positioned(
                  left: 16,
                  bottom: 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Zoom: ${_currentZoom.toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showDestinationBottomSheet(Destination dest) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    dest.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dest.location,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text('${dest.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showRoute(dest);
                    },
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Chỉ đường'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationDetailScreen(destination: dest),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Xem chi tiết'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MapButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color ?? Colors.black87, size: 22),
      ),
    );
  }
}
