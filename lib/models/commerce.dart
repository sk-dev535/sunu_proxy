class Commerce {
  final String id;
  final String nom;
  final String categorie;
  final String description;
  final String telephone;
  final double latitude;
  final double longitude;
  final String heureOuverture; // ex: "07:00"
  final String heureFermeture; // ex: "20:00"

  Commerce({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.telephone,
    required this.latitude,
    required this.longitude,
    this.heureOuverture = '',
    this.heureFermeture = '',
  });

  factory Commerce.fromFirestore(String id, Map<String, dynamic> data) {
    return Commerce(
      id: id,
      nom: data['nom'] ?? '',
      categorie: data['categorie'] ?? '',
      description: data['description'] ?? '',
      telephone: data['telephone'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      heureOuverture: data['heureOuverture'] ?? '',
      heureFermeture: data['heureFermeture'] ?? '',
    );
  }

  /// true = ouvert, false = fermé, null = horaires non renseignés
  bool? get estOuvert {
    final o = _enMinutes(heureOuverture);
    final f = _enMinutes(heureFermeture);
    if (o == null || f == null) return null;
    final now = DateTime.now();
    final cur = now.hour * 60 + now.minute;
    return o <= f ? (cur >= o && cur < f) : (cur >= o || cur < f);
  }

  static int? _enMinutes(String h) {
    final p = h.split(':');
    if (p.length != 2) return null;
    final hh = int.tryParse(p[0]);
    final mm = int.tryParse(p[1]);
    if (hh == null || mm == null) return null;
    return hh * 60 + mm;
  }
}