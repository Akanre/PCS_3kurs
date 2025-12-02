import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const GeoSensorsApp());

class GeoSensorsApp extends StatelessWidget {
  const GeoSensorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo & Sensors',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      home: const GeoSensorsPage(),
    );
  }
}

class GeoSensorsPage extends StatefulWidget {
  const GeoSensorsPage({super.key});
  @override
  State<GeoSensorsPage> createState() => _GeoSensorsPageState();
}

class _GeoSensorsPageState extends State<GeoSensorsPage> {
  Position? _position;
  String _address = '–';
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    setState(() {
      _position = pos;
      _address =
          '${placemarks.first.locality}, ${placemarks.first.street ?? ''}';
    });
  }

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((event) {
      setState(() => _accelerometerValues = [event.x, event.y, event.z]);
    });

    gyroscopeEvents.listen((event) {
      setState(() => _gyroscopeValues = [event.x, event.y, event.z]);
    });
  }

  Widget _buildInfoCard(String title, String value, {IconData? icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: Colors.blue.shade700),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo & Sensors'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Location Button
              FilledButton(
                onPressed: _getLocation,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Определить местоположение',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Location Info Section
              Text(
                'Геолокация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Координаты',
                _position != null
                    ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                    : '–',
                icon: Icons.my_location_outlined,
              ),
              _buildInfoCard('Адрес', _address, icon: Icons.place_outlined),
              const SizedBox(height: 24),

              // Sensors Section
              Text(
                'Датчики',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Акселерометр',
                _accelerometerValues != null
                    ? 'X: ${_accelerometerValues![0].toStringAsFixed(2)}\n'
                          'Y: ${_accelerometerValues![1].toStringAsFixed(2)}\n'
                          'Z: ${_accelerometerValues![2].toStringAsFixed(2)}'
                    : '–',
                icon: Icons.directions_run_outlined,
              ),
              _buildInfoCard(
                'Гироскоп',
                _gyroscopeValues != null
                    ? 'X: ${_gyroscopeValues![0].toStringAsFixed(2)}\n'
                          'Y: ${_gyroscopeValues![1].toStringAsFixed(2)}\n'
                          'Z: ${_gyroscopeValues![2].toStringAsFixed(2)}'
                    : '–',
                icon: Icons.sync_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
