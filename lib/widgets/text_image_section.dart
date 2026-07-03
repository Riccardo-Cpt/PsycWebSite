import 'package:flutter/material.dart';
import 'section_image.dart';

class TextImageSection extends StatelessWidget {
  final Widget content;
  final String imagePath;
  final double aspectRatio;
  final bool imageOnLeft;
  final Color? backgroundColor;
  final double maxWidth;
  final EdgeInsets padding;

  const TextImageSection({
    super.key,
    required this.content,
    required this.imagePath,
    required this.aspectRatio,
    this.imageOnLeft = false,
    this.backgroundColor,
    this.maxWidth = 1100,
    this.padding = const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor ?? Colors.transparent,
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final image = buildSectionImage(imagePath, aspectRatio);
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, const SizedBox(height: 32), image],
                );
              }
              final children = imageOnLeft
                  ? <Widget>[
                      Expanded(flex: 2, child: image),
                      const SizedBox(width: 40),
                      Expanded(flex: 3, child: content),
                    ]
                  : <Widget>[
                      Expanded(flex: 3, child: content),
                      const SizedBox(width: 40),
                      Expanded(flex: 2, child: image),
                    ];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            },
          ),
        ),
      ),
    );
  }
}
