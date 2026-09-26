class Commerce {
  final String id;
  final String nom;
  final String categorie;
  final String description;
  final String telephone;
  final double latitude;
  final double longitude;

  Commerce({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    required this.telephone,
    required this.latitude,
    required this.longitude,
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
    );
  }
}