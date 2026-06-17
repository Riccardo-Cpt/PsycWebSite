# ValoriSection Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the rigid 2×2 card grid in `_ValoriSection` with a fluid alternating-row layout where each value occupies a full-width band with icon/text side by side, icon flipping sides on alternate rows, and teal/transparent background alternation.

**Architecture:** Replace `_ValoriSection` and `_ValoreCard` in `lib/pages/home_page.dart` with `_ValoriSection` (renders title + list of `_ValoreRow` widgets) and `_ValoreRow` (renders one full-width band, handles wide/narrow layout via `LayoutBuilder`). No Card, no Wrap, no elevation.

**Tech Stack:** Flutter, Dart, Material widgets (`Container`, `Row`, `Column`, `LayoutBuilder`, `Icon`, `Text`)

---

### Task 1: Replace `_ValoriSection` and `_ValoreCard` with the new alternating-row layout

**Files:**
- Modify: `lib/pages/home_page.dart:215-323`

- [ ] **Step 1: Delete the old `_ValoriSection` and `_ValoreCard` classes (lines 215–323) and replace with the following code**

```dart
class _ValoriSection extends StatelessWidget {
  const _ValoriSection();

  static const _valori = [
    (Icons.favorite, 'Empatia e ascolto',
        'Ogni persona è ascoltata senza giudizio in un ambiente sicuro e accogliente.'),
    (Icons.lock, 'Riservatezza assoluta',
        'Il segreto professionale è un pilastro fondamentale del rapporto terapeutico.'),
    (Icons.science, 'Approccio basato sull\'evidenza',
        'Tecniche validate scientificamente adattate alle esigenze del singolo.'),
    (Icons.spa, 'Spazio sicuro',
        'Un luogo fisico e mentale dove esprimersi liberamente senza timore.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
          alignment: Alignment.center,
          color: Colors.transparent,
          child: const Text(
            'I miei valori',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B7A1D),
            ),
          ),
        ),
        ...List.generate(_valori.length, (i) {
          final v = _valori[i];
          return _ValoreRow(
            icon: v.$1,
            titolo: v.$2,
            descrizione: v.$3,
            tinted: i.isOdd,
            iconOnLeft: i.isEven,
          );
        }),
      ],
    );
  }
}

class _ValoreRow extends StatelessWidget {
  final IconData icon;
  final String titolo;
  final String descrizione;
  final bool tinted;
  final bool iconOnLeft;

  const _ValoreRow({
    required this.icon,
    required this.titolo,
    required this.descrizione,
    required this.tinted,
    required this.iconOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tinted
        ? const Color(0xFF3B7A1D).withOpacity(0.12)
        : Colors.transparent;
    final titleColor =
        tinted ? Colors.white : const Color(0xFF3B7A1D);
    final descColor =
        tinted ? Colors.white70 : Colors.black87;
    final iconColor =
        tinted ? Colors.white : const Color(0xFF3B7A1D);

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final iconWidget =
                  Icon(icon, size: 68, color: iconColor);
              final textWidget = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titolo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descrizione,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: descColor,
                      ),
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    iconWidget,
                    const SizedBox(height: 16),
                    Text(
                      titolo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descrizione,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: descColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: iconOnLeft
                    ? [iconWidget, const SizedBox(width: 24), textWidget]
                    : [textWidget, const SizedBox(width: 24), iconWidget],
              );
            },
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the app and verify the section visually**

```bash
flutter run -d chrome
```

Expected: 4 full-width bands visible on the home page under "I miei valori". Bands 0 and 2 (Empatia, Approccio) are transparent. Bands 1 and 3 (Riservatezza, Spazio sicuro) have a light teal tint. Icons alternate left/right. No cards, no grid.

Resize the browser below 600px width and verify the icon stacks above text in each band with centered text.

- [ ] **Step 3: Commit**

```bash
git add lib/pages/home_page.dart
git commit -m "feat(home): redesign ValoriSection with alternating-row layout"
```
