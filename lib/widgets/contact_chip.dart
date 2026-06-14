import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Apre Google Maps cercando [indirizzo].
Future<void> apriMappa(String indirizzo) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1'
    '&query=${Uri.encodeComponent(indirizzo)}',
  );
  // Su web apre una nuova scheda del browser ('_blank'); su mobile/desktop
  // usa il comportamento predefinito della piattaforma.
  await launchUrl(uri, webOnlyWindowName: '_blank');
}

/// Avvia una chiamata verso [telefono] (apre il dialer / app telefono).
Future<void> chiamaTelefono(String telefono) async {
  // Rimuove spazi e separatori dal numero per uno schema 'tel:' valido.
  final numero = telefono.replaceAll(RegExp(r'[\s()-]'), '');
  await launchUrl(Uri(scheme: 'tel', path: numero));
}

/// Apre il client di posta con una nuova email verso [email].
Future<void> inviaEmail(String email) async {
  await launchUrl(Uri(scheme: 'mailto', path: email));
}

/// Riga "icona + testo" usata per i contatti cliccabili (telefono, indirizzo,
/// email). Se [onTap] è valorizzato il chip è cliccabile, mostra il cursore a
/// mano, si sottolinea e cambia colore al passaggio del mouse.
///
/// I colori sono parametrizzabili così lo stesso widget si adatta sia a sfondi
/// scuri (testo bianco, default — vedi footer della HomePage) sia a sfondi
/// chiari (es. footer "Vuoi candidarti?" della pagina Posizioni).
class ContactChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  /// Colore di base di icona e testo.
  final Color color;

  /// Colore mostrato al passaggio del mouse sui contatti cliccabili.
  final Color hoverColor;
  final double fontSize;
  final FontWeight? fontWeight;

  const ContactChip({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.color = Colors.white,
    this.hoverColor = const Color(0xFFFFB347),
    this.fontSize = 14,
    this.fontWeight,
  });

  @override
  State<ContactChip> createState() => _ContactChipState();
}

class _ContactChipState extends State<ContactChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null;
    final color = clickable && _hovering ? widget.hoverColor : widget.color;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(widget.icon, color: color, size: 18),
        const SizedBox(width: 6),
        // Flexible permette al testo lungo (es. l'indirizzo) di andare a capo
        // entro la larghezza disponibile invece di sforare su schermi stretti.
        Flexible(
          child: Text(
            widget.text,
            style: TextStyle(
              color: color,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              decoration: clickable ? TextDecoration.underline : null,
              decorationColor: color,
            ),
          ),
        ),
      ],
    );

    if (!clickable) return row;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(onTap: widget.onTap, child: row),
    );
  }
}
