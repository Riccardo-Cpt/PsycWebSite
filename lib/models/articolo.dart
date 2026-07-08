class Articolo {
  final int id;
  final String titolo;
  final String? corpo;
  final DateTime? pubblicatoAt;
  final String? immagineUrl;

  const Articolo({
    required this.id,
    required this.titolo,
    this.corpo,
    this.pubblicatoAt,
    this.immagineUrl,
  });

  factory Articolo.fromJson(Map<String, dynamic> json) => Articolo(
        id: json['id'] as int,
        titolo: json['titolo'] as String,
        corpo: json['corpo'] as String?,
        pubblicatoAt: json['pubblicato_at'] != null
            ? DateTime.parse(json['pubblicato_at'] as String)
            : null,
        immagineUrl: json['immagine_url'] as String?,
      );

}
