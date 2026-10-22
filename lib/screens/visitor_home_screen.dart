import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/commerce.dart';
import 'commerce_detail_screen.dart';
import 'map_screen.dart';

const _vert = Color(0xFF1B7A5C);
const _vertFonce = Color(0xFF0F4D3A);
const _fond = Color(0xFFF5F5F0);

class _Categorie {
  final String nom;
  final IconData icone;
  final List<String> motsCles;
  const _Categorie(this.nom, this.icone, this.motsCles);
}

const List<_Categorie> _categories = [
  _Categorie('Alimentation', Icons.shopping_cart,
      ['alim', 'epicer', 'boulang', 'patisser', 'restaur', 'fruit', 'legume', 'boucher', 'poisson']),
  _Categorie('Couture', Icons.checkroom,
      ['coutur', 'mode', 'tailleur', 'vetement', 'tissu', 'habit']),
  _Categorie('Coiffure', Icons.content_cut, ['coiff', 'barbier', 'tresse']),
  _Categorie('Réparation', Icons.build,
      ['repar', 'mecan', 'garage', 'plomb', 'electri', 'phone', 'menuis']),
  _Categorie('Beauté', Icons.spa,
      ['beaut', 'esthet', 'maquill', 'cosmet', 'manucure', 'ongle']),
  _Categorie('Autres', Icons.grid_view, []),
];

const Map<String, List<String>> _besoins = {
  'Alimentation': [
    'alimentation', 'gateau', 'anniversaire', 'boulangerie', 'boulanger',
    'patisserie', 'pain', 'baguette', 'viennoiserie', 'repas', 'manger',
    'restaurant', 'dejeuner', 'diner', 'fruit', 'legume', 'viande', 'poisson',
    'epicerie', 'boisson', 'courses', 'boucherie', 'cuisine', 'traiteur',
  ],
  'Couture': [
    'couture', 'couturier', 'couturiere', 'robe', 'mariage', 'tissu',
    'tailleur', 'vetement', 'habit', 'costume', 'boubou', 'pagne', 'retouche',
    'ourlet', 'mode', 'confection',
  ],
  'Coiffure': [
    'coiffure', 'coiffeur', 'coiffeuse', 'coupe', 'cheveux', 'tresse',
    'tresses', 'barbier', 'barbe', 'brushing', 'tissage', 'perruque', 'salon',
  ],
  'Réparation': [
    'reparation', 'reparer', 'panne', 'frigo', 'telephone', 'ecran',
    'plomberie', 'plombier', 'fuite', 'electricite', 'electricien', 'moto',
    'voiture', 'mecanicien', 'mecanique', 'garage', 'climatiseur',
    'television', 'soudure', 'menuisier', 'menuiserie', 'refrigerateur',
    'ordinateur',
  ],
  'Beauté': [
    'beaute', 'maquillage', 'ongles', 'manucure', 'massage', 'soin',
    'parfum', 'esthetique', 'epilation', 'henne', 'cosmetique',
  ],
  'Autres': [
    'pharmacie', 'medicament', 'sante', 'ordonnance', 'pharmacien',
    'librairie', 'livre', 'papeterie', 'cahier', 'stylo',
    'quincaillerie', 'bricolage', 'outillage', 'peinture',
  ],
};

const Set<String> _motsVides = {
  'cherche', 'chercher', 'pour', 'avec', 'dans', 'mon', 'mes', 'une', 'des',
  'les', 'aux', 'pres', 'proche', 'besoin', 'voudrais', 'veux', 'trouver',
  'quelqu', 'quelquun', 'sur', 'qui', 'ouvert', 'ouverte', 'maintenant',
  'svp', 'plait', 'commerce', 'boutique',
};

String _norm(String s) {
  const from = 'àâäéèêëîïôöùûüç';
  const to = 'aaaeeeeiioouuuc';
  var r = s.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    r = r.replaceAll(from[i], to[i]);
  }
  return r;
}

List<String> _mots(String texte) {
  return _norm(texte)
      .split(RegExp(r'[^a-z0-9]+'))
      .where((m) => m.length >= 3 && !_motsVides.contains(m))
      .toList();
}

Set<String> _categoriesVisees(List<String> mots) {
  final res = <String>{};
  _besoins.forEach((cat, cles) {
    for (final m in mots) {
      if (cles.any((k) => k.contains(m) || m.contains(k))) {
        res.add(cat);
        break;
      }
    }
  });
  return res;
}

_Categorie _categorieDe(Commerce c) {
  final cat = _norm(c.categorie);
  for (final k in _categories) {
    if (k.nom != 'Autres' && k.motsCles.any((m) => cat.contains(m))) {
      return k;
    }
  }
  return _categories.last;
}

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key});

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  String _recherche = '';
  String? _categorieSelectionnee;
  bool _ouvertSeulement = false;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _getPosition().then((pos) {
      if (!mounted) return;
      setState(() {
        _position = pos;
      });
    });
  }

  Future<Position?> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  String? _distanceTexte(Commerce c) {
    if (_position == null) return null;
    if (c.latitude == 0 && c.longitude == 0) return 'position inconnue';
    final m = Geolocator.distanceBetween(
        _position!.latitude, _position!.longitude, c.latitude, c.longitude);
    return m < 1000
        ? '${m.round()} m'
        : '${(m / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  bool _correspond(Commerce c, List<String> mots, Set<String> categoriesVisees) {
    if (mots.isEmpty) return true;
    final texte = _norm('${c.nom} ${c.description} ${c.categorie}');
    if (mots.any((m) => texte.contains(m))) return true;
    return categoriesVisees.contains(_categorieDe(c).nom);
  }

  Widget _titre(String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(texte,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _barreRecherche() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Que cherchez-vous ? (ex : gâteau, robe, frigo…)',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _recherche = value;
        });
      },
    );
  }

  Widget _puceOuvert() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FilterChip(
        avatar: const Icon(Icons.access_time, size: 18),
        label: const Text('Ouvert maintenant'),
        selected: _ouvertSeulement,
        selectedColor: _vert.withOpacity(0.2),
        checkmarkColor: _vert,
        onSelected: (v) {
          setState(() {
            _ouvertSeulement = v;
          });
        },
      ),
    );
  }

  Widget _banniere() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD8EEDF), Color(0xFFB8E0C6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Soutenons\nnos commerçants\nlocaux !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _vertFonce,
                height: 1.3,
              ),
            ),
          ),
          Icon(Icons.storefront, size: 72, color: _vert.withOpacity(0.7)),
        ],
      ),
    );
  }

  Widget _tuileCategorie(_Categorie k) {
    final selectionnee = _categorieSelectionnee == k.nom;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _categorieSelectionnee = selectionnee ? null : k.nom;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectionnee ? _vert : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(k.icone, size: 28, color: selectionnee ? Colors.white : _vert),
            const SizedBox(height: 6),
            Text(
              k.nom,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selectionnee ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteCommerce(Commerce c) {
    final cat = _categorieDe(c);
    final dist = _distanceTexte(c);
    final ouvert = c.estOuvert;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommerceDetailScreen(commerce: c),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _vert.withOpacity(0.12),
                child: Icon(cat.icone, color: _vert),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nom,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      dist == null ? c.categorie : '${c.categorie} • $dist',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _NoteMoyenne(commerceId: c.id),
                        if (ouvert != null)
                          Text(
                            ouvert
                                ? 'Ouvert • ${c.heureOuverture} - ${c.heureFermeture}'
                                : 'Fermé • ouvre à ${c.heureOuverture}',
                            style: TextStyle(
                              color: ouvert ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listeCommerces() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('commerces').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text("Aucun commerce pour l'instant.")),
          );
        }

        final mots = _mots(_recherche);
        final visees = _categoriesVisees(mots);
        final qn = _norm(_recherche);
        final veutOuvert = _ouvertSeulement ||
            qn.contains('ouvert') ||
            qn.contains('maintenant');

        final commerces = snapshot.data!.docs
            .map((doc) => Commerce.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>))
            .where((c) {
          final matchTexte = _correspond(c, mots, visees);
          
          bool matchCategorie = true;
          if (_categorieSelectionnee != null) {
            if (_categorieSelectionnee == 'Autres') {
              matchCategorie = _categorieDe(c).nom == 'Autres';
            } else {
              matchCategorie = _categorieDe(c).nom == _categorieSelectionnee;
            }
          }

          final matchOuvert = !veutOuvert || c.estOuvert == true;
          return matchTexte && matchCategorie && matchOuvert;
        }).toList();

        if (_position != null) {
          commerces.sort((a, b) {
            double distA = Geolocator.distanceBetween(_position!.latitude,
                _position!.longitude, a.latitude, a.longitude);
            double distB = Geolocator.distanceBetween(_position!.latitude,
                _position!.longitude, b.latitude, b.longitude);
            return distA.compareTo(distB);
          });
        }

        if (commerces.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                veutOuvert
                    ? 'Aucun commerce ouvert pour cette recherche.'
                    : 'Aucun résultat pour cette recherche.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: commerces.map(_carteCommerce).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        title: const Text('SunuProxi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _fond,
        foregroundColor: _vertFonce,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Voir la carte',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    userLat: _position?.latitude,
                    userLng: _position?.longitude,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _barreRecherche(),
          const SizedBox(height: 8),
          _puceOuvert(),
          if (_position == null)
            const Padding(
              padding: EdgeInsets.only(top: 2, left: 4),
              child: Text(
                'Localisation indisponible : les commerces ne sont pas triés par distance.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 12),
          _banniere(),
          const SizedBox(height: 18),
          _titre('Catégories'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: _categories.map(_tuileCategorie).toList(),
          ),
          const SizedBox(height: 18),
          _titre(_position == null ? 'Commerces' : 'Commerces à proximité'),
          _listeCommerces(),
        ],
      ),
    );
  }
}

class _NoteMoyenne extends StatelessWidget {
  final String commerceId;
  const _NoteMoyenne({required this.commerceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('commerces')
          .doc(commerceId)
          .collection('avis')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();
        final notes = docs
            .map<num>((d) => ((d.data() as Map<String, dynamic>)['note'] ?? 0) as num)
            .toList();
        final moyenne = notes.reduce((a, b) => a + b) / notes.length;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 2),
            Text(
              '${moyenne.toStringAsFixed(1).replaceAll('.', ',')} (${notes.length})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        );
      },
    );
  }
}