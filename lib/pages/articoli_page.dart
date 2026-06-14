import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../database/app_database.dart';
import '../widgets/nav_drawer.dart';

class ArticoliPage extends StatefulWidget {
  const ArticoliPage({super.key});

  @override
  State<ArticoliPage> createState() => _ArticoliPageState();
}

class _ArticoliPageState extends State<ArticoliPage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _articleKeys = {};
  double _scrollOffset = 0;
  late final AnimationController _navCtrl;
  late final Animation<Offset> _navSlide;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset.clamp(0.0, 80.0);
      if ((offset - _scrollOffset).abs() > 0.5) {
        setState(() => _scrollOffset = offset);
      }
    });
    _navCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _navSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _navCtrl.dispose();
    super.dispose();
  }

  void _toggleNav() {
    if (_navCtrl.isCompleted) {
      _navCtrl.reverse();
    } else {
      _navCtrl.forward();
    }
  }

  void _closeNav() => _navCtrl.reverse();

  void _showArticleIndex(List<ArticoliData> articoli) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        alignment: Alignment.topRight,
        insetPadding: const EdgeInsets.only(right: 8, top: kToolbarHeight + 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Indice articoli',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: articoli.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Nessun articolo',
                            style: TextStyle(color: Colors.black54)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: articoli.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(articoli[i].titolo),
                          subtitle: Text(articoli[i].dataPubblicazione),
                          onTap: () => _scrollToArticle(i, articoli),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToArticle(int index, List<ArticoliData> articoli) {
    if (index >= articoli.length) return;
    Navigator.pop(context);
    final id = articoli[index].id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _articleKeys[id]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _navCtrl,
      builder: (context, _) {
        final t = (_scrollOffset / 80.0).clamp(0.0, 1.0);
        final appBarBg =
            Color.lerp(const Color(0xFFFAFAFA), const Color(0xFFEEEEEE), t)!;
        final navOpen = _navCtrl.value > 0.01;

        return StreamBuilder<List<ArticoliData>>(
          stream: appDatabase.articoliDao.watchTutti(),
          builder: (context, snapshot) {
            final articoli = snapshot.data ?? [];
            for (final a in articoli) {
              _articleKeys.putIfAbsent(a.id, () => GlobalKey());
            }
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: appBarBg,
                foregroundColor: const Color(0xFF1E6370),
                elevation: t * 3.0,
                scrolledUnderElevation: 0,
                title: InkWell(
                  onTap: () => context.go('/'),
                  child: const Text(
                    'Dr.ssa Maria Bianchi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E6370)),
                  ),
                ),
                actions: [
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Center(
                      child: Text(
                        'Naviga nel sito',
                        style: TextStyle(
                            color: Color(0xFF1E6370),
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        RotationTransition(
                          turns: animation,
                          child:
                              FadeTransition(opacity: animation, child: child),
                        ),
                    child: IconButton(
                      key: ValueKey(navOpen),
                      icon: Icon(navOpen ? Icons.close : Icons.menu),
                      tooltip: navOpen ? 'Chiudi menu' : 'Menu',
                      onPressed: _toggleNav,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'I miei articoli',
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E6370)),
                              ),
                            ),
                            const Text(
                              'Naviga tra gli articoli',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E6370)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.list),
                              tooltip: 'Indice articoli',
                              onPressed: () => _showArticleIndex(articoli),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (articoli.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Text('Nessun articolo pubblicato.',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black54)),
                            ),
                          )
                        else
                          ...articoli.asMap().entries.map((entry) {
                            final i = entry.key;
                            final a = entry.value;
                            return Padding(
                              key: _articleKeys[a.id],
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _ArticoloCard(
                                articolo: a,
                                initiallyExpanded: i == 0,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  if (navOpen)
                    GestureDetector(
                      onTap: _closeNav,
                      child: Container(
                        color: Colors.black
                            .withValues(alpha: 0.3 * _navCtrl.value),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: SlideTransition(
                      position: _navSlide,
                      child: NavDrawer(onClose: _closeNav),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}

class _ArticoloCard extends StatefulWidget {
  final ArticoliData articolo;
  final bool initiallyExpanded;
  const _ArticoloCard(
      {required this.articolo, required this.initiallyExpanded});

  @override
  State<_ArticoloCard> createState() => _ArticoloCardState();
}

class _ArticoloCardState extends State<_ArticoloCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.articolo;
    return Card(
      elevation: 2,
      child: _expanded ? _buildExpanded(a) : _buildCollapsed(a),
    );
  }

  Widget _buildCollapsed(ArticoliData a) {
    return ListTile(
      leading: const Icon(Icons.expand_more, color: Color(0xFF1E6370)),
      title: Text(a.titolo,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(a.dataPubblicazione),
      onTap: () => setState(() => _expanded = true),
    );
  }

  Widget _buildExpanded(ArticoliData a) {
    return InkWell(
      onTap: () => setState(() => _expanded = false),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final imageWidget = a.immagine != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      a.immagine!,
                      fit: BoxFit.cover,
                    ),
                  )
                : null;

            final textContent = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.titolo,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(a.dataPubblicazione,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 12),
                Text(a.corpo,
                    style: const TextStyle(fontSize: 16, height: 1.6)),
              ],
            );

            if (imageWidget == null) {
              return SizedBox(width: double.infinity, child: textContent);
            }

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: imageWidget),
                  const SizedBox(height: 16),
                  textContent,
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: imageWidget),
                  const SizedBox(width: 20),
                  Expanded(child: textContent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
