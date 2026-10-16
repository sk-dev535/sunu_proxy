import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/commerce.dart';
import 'commerce_detail_screen.dart';

const _vert = Color(0xFF1B7A5C);

class MapScreen extends StatefulWidget {
  final double? userLat;
  final double? userLng;

  const MapScreen({super.key, this.userLat, this.userLng});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Commerce? _selection;

  bool get _aPosition => widget.userLat != null && widget.userLng != null;

  LatLng get _centre => _aPosition
      ? LatLng(widget.userLat!, widget.userLng!)
      : const LatLng(16.0326, -16.4818); // Saint-Louis par défaut

  Color _couleurPin(Commerce c) {
    final ouvert = c.estOuvert;
    if (ouvert == true) return Colors.green;
    if (ouvert == false) return Colors.red;
    return _vert;
  }

  String? _distanceTexte(Commerce c) {
    if (!_aPosition) return null;
    final m = const Distance()
        .as(LengthUnit.Meter, _centre, LatLng(c.latitude, c.longitude));
    return m < 1000
        ? '${m.round()} m'
        : '${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  Widget _carteSelection(Commerce c) {
    final ouvert = c.estOuvert;
    final dist = _distanceTexte(c);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.nom,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              dist == null ? c.categorie : '${c.categorie} • $dist',
              style: const TextStyle(color: Colors.grey),
            ),
            if (ouvert != null) ...[
              const SizedBox(height: 4),
              Text(
                ouvert
                    ? 'Ouvert • ${c.heureOuverture} - ${c.heureFermeture}'
                    : 'Fermé • ouvre à ${c.heureOuverture}',
                style: TextStyle(
                  color: ouvert ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommerceDetailScreen(commerce: c),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vert,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Voir la fiche'),
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
        title: const Text('Carte des commerces'),
        backgroundColor: _vert,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('commerces').snapshots(),
        builder: (context, snapshot) {
          final commerces = (snapshot.data?.docs ?? [])
              .map((d) => Commerce.fromFirestore(
                  d.id, d.data() as Map<String, dynamic>))
              .where((c) => !(c.latitude == 0 && c.longitude == 0))
              .toList();

          final markers = <Marker>[
            for (final c in commerces)
              Marker(
                point: LatLng(c.latitude, c.longitude),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => setState(() => _selection = c),
                  child: Icon(Icons.location_on, size: 44, color: _couleurPin(c)),
                ),
              ),
            if (_aPosition)
              Marker(
                point: _centre,
                width: 22,
                height: 22,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
          ];

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _centre,
                  initialZoom: 14,
                  onTap: (tapPosition, point) =>
                      setState(() => _selection = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sunu_proxy',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              if (_selection != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _carteSelection(_selection!),
                ),
              if (commerces.isEmpty &&
                  snapshot.connectionState != ConnectionState.waiting)
                const Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Aucun commerce avec une position enregistrée.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}