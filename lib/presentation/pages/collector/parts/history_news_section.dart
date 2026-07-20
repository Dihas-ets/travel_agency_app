import 'dart:async';
import 'package:flutter/material.dart';
import 'package:code_initial/presentation/pages/collector/parts/reservation_flow.dart';
// Historique percepteur et actualites affichees dans l espace percepteur.

enum CollectorHistoryScope { reservations, absent, present }

class CollectorHistoryPage extends StatefulWidget {
  const CollectorHistoryPage({super.key});

  @override
  State<CollectorHistoryPage> createState() => CollectorHistoryPageState();
}

class CollectorHistoryPageState extends State<CollectorHistoryPage> {
  CollectorHistoryScope _scope = CollectorHistoryScope.reservations;

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Historique voyage',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _HistoryActionButton(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Réservation',
                    selected: _scope == CollectorHistoryScope.reservations,
                    onTap: () => setState(
                      () => _scope = CollectorHistoryScope.reservations,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HistoryActionButton(
                    icon: Icons.person_off_rounded,
                    label: 'Absent',
                    selected: _scope == CollectorHistoryScope.absent,
                    onTap: () =>
                        setState(() => _scope = CollectorHistoryScope.absent),
                  ),
                  const SizedBox(width: 8),
                  _HistoryActionButton(
                    icon: Icons.how_to_reg_rounded,
                    label: 'Présent',
                    selected: _scope == CollectorHistoryScope.present,
                    onTap: () =>
                        setState(() => _scope = CollectorHistoryScope.present),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (_scope == CollectorHistoryScope.reservations)
                Expanded(
                  child: CollectorReservationList(
                    onNewReservation: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CollectorReservationPage(),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                )
              else
                Expanded(
                  child: CollectorAttendanceList(
                    title: _scope == CollectorHistoryScope.absent
                        ? 'Passagers absents'
                        : 'Passagers présents',
                    emptyMessage: _scope == CollectorHistoryScope.absent
                        ? 'Aucun passager absent enregistré.'
                        : 'Aucun passager présent enregistré.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectorReservationList extends StatelessWidget {
  final VoidCallback onNewReservation;

  const CollectorReservationList({super.key, required this.onNewReservation});

  @override
  Widget build(BuildContext context) {
    final reservations = CollectorReservationStore.reservations;

    return ListView(
      children: [
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onNewReservation,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nouvelle réservation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (reservations.isEmpty)
          const CollectorEmptyCard(
            title: 'Aucune réservation',
            message:
                'Les réservations faites par le percepteur apparaîtront ici.',
          )
        else
          ...reservations.map((item) => CollectorReservationCard(item: item)),
      ],
    );
  }
}

class _HistoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _HistoryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);
    return Expanded(
      child: SizedBox(
        height: 58,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: selected ? Colors.white : deepBlue,
            side: BorderSide(color: deepBlue.withValues(alpha: 0.18)),
            backgroundColor: selected ? const Color(0xFF16A34A) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectorNewsArticle {
  final String category;
  final String title;
  final String date;
  final String image;
  final String excerpt;
  final List<String> body;

  const CollectorNewsArticle({
    required this.category,
    required this.title,
    required this.date,
    required this.image,
    required this.excerpt,
    required this.body,
  });
}

const List<CollectorNewsArticle> collectorNewsArticles = [
  CollectorNewsArticle(
    category: 'Annonces',
    title: 'Nouveau départ sur Gouré',
    date: '28/03/2026',
    image: 'assets/images/coli1.jpg',
    excerpt:
        'Fofana renforce son réseau avec un nouveau départ pensé pour faciliter les déplacements réguliers.',
    body: [
      'Fofana informe son aimable clientèle de la mise en place d’un nouveau départ sur l’axe Gouré afin de rendre les voyages plus simples, plus réguliers et plus confortables.',
      'Cette nouvelle desserte répond à la demande des voyageurs qui souhaitent mieux organiser leurs déplacements entre les grandes villes et les localités desservies par Fofana.',
      'Les clients sont invités à se rapprocher des agences Fofana pour confirmer les horaires, les disponibilités et les conditions de réservation.',
    ],
  ),
  CollectorNewsArticle(
    category: 'Annonces',
    title: "Renforcement des départs sur l'axe Tchaourou",
    date: '25/03/2026',
    image: 'assets/images/coli2.jpg',
    excerpt:
        'De nouveaux horaires sont ajoutés pour offrir plus de flexibilité aux voyageurs.',
    body: [
      'Pour mieux accompagner les besoins de mobilité, Fofana annonce un renforcement progressif des départs sur l’axe Tchaourou.',
      'Cette organisation permet aux voyageurs de choisir des créneaux plus adaptés à leurs programmes personnels, professionnels ou familiaux.',
      'Les équipes en agence restent disponibles pour orienter les clients et les aider à choisir le départ le plus pratique.',
    ],
  ),
  CollectorNewsArticle(
    category: 'Presse',
    title: 'Fofana modernise l’accueil dans ses agences',
    date: '18/03/2026',
    image: 'assets/images/coli3.jpg',
    excerpt:
        'Un parcours client plus fluide est déployé pour améliorer l’achat de tickets et l’information voyageur.',
    body: [
      'Fofana poursuit l’amélioration de l’expérience client dans ses agences avec des espaces plus lisibles, un accueil renforcé et une meilleure orientation des voyageurs.',
      'L’objectif est de réduire l’attente, d’améliorer la qualité des informations et de rendre chaque étape du voyage plus agréable.',
      'Cette modernisation s’inscrit dans une démarche continue de qualité de service.',
    ],
  ),
  CollectorNewsArticle(
    category: 'Conseils',
    title: 'Bien préparer son voyage avec Fofana',
    date: '12/03/2026',
    image: 'assets/images/coli4.jpg',
    excerpt:
        'Quelques réflexes simples pour voyager sereinement et éviter les oublis avant le départ.',
    body: [
      'Avant chaque départ, Fofana recommande aux voyageurs de vérifier leur ticket, leur pièce d’identité et l’heure de présentation en agence.',
      'Il est conseillé d’arriver suffisamment tôt afin d’effectuer les formalités sans stress et d’embarquer dans de bonnes conditions.',
      'Pour les bagages et colis, les équipes Fofana peuvent préciser les règles applicables selon le trajet choisi.',
    ],
  ),
  CollectorNewsArticle(
    category: 'Communiqués',
    title: 'Suivi des colis disponible dans les agences Fofana',
    date: '08/03/2026',
    image: 'assets/images/logo_fofana.png',
    excerpt:
        'Les clients peuvent obtenir des informations sur leurs colis directement auprès des points Fofana.',
    body: [
      'Fofana rappelle à sa clientèle que le suivi des colis est disponible auprès de ses agences et points de contact.',
      'Les clients sont invités à conserver leurs références d’envoi afin de faciliter les vérifications et accélérer la prise en charge.',
      'Ce service accompagne les voyageurs et expéditeurs dans une logique de proximité et de fiabilité.',
    ],
  ),
];

class CollectorNewsSection extends StatefulWidget {
  const CollectorNewsSection({super.key});

  @override
  State<CollectorNewsSection> createState() => CollectorNewsSectionState();
}

class CollectorNewsSectionState extends State<CollectorNewsSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(
        () => _pageIndex = (_pageIndex + 1) % collectorNewsArticles.length,
      );
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    void openDetail(CollectorNewsArticle article) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CollectorNewsDetailPage(article: article),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actualités',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CollectorNewsListPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Voir plus',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 138,
          child: PageView.builder(
            controller: _pageController,
            itemCount: collectorNewsArticles.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = collectorNewsArticles[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CollectorNewsHeroTile(
                  article: item,
                  compact: true,
                  onTap: () => openDetail(item),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(collectorNewsArticles.length, (i) {
            final isActive = i == _pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 10,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? green : Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class CollectorNewsHeroTile extends StatelessWidget {
  final CollectorNewsArticle article;
  final VoidCallback onTap;
  final bool compact;

  const CollectorNewsHeroTile({super.key, 
    required this.article,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                article.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF8FBFF),
                  child: const Icon(Icons.image_not_supported_rounded),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: 0.43)),
              Positioned(
                left: 12,
                top: 12,
                child: CollectorNewsCategoryPill(category: article.category),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: compact ? 14 : 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Publié le ${article.date}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      article.title,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 14.2 : 18,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 13.2,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectorNewsCategoryPill extends StatelessWidget {
  final String category;

  const CollectorNewsCategoryPill({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class CollectorNewsListPage extends StatelessWidget {
  const CollectorNewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actualités',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          itemCount: collectorNewsArticles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final article = collectorNewsArticles[index];
            return SizedBox(
              height: 178,
              child: CollectorNewsHeroTile(
                article: article,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CollectorNewsDetailPage(article: article),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CollectorNewsDetailPage extends StatelessWidget {
  final CollectorNewsArticle article;

  const CollectorNewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF0B4F2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Actualité',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            SizedBox(
              height: 230,
              child: CollectorNewsHeroTile(article: article, onTap: () {}),
            ),
            const SizedBox(height: 18),
            Text(
              article.title,
              style: const TextStyle(
                color: deepBlue,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publié le ${article.date}',
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.excerpt,
              style: const TextStyle(
                color: Color(0xFF5F6B86),
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            ...article.body.map(
              (paragraph) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  paragraph,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectorTab {
  final String title;
  final IconData icon;

  const CollectorTab(this.title, this.icon);
}


