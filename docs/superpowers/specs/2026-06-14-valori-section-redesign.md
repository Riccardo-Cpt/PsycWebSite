# _ValoriSection Redesign

## Goal

Replace the current rigid 2×2 card grid with a fluid alternating-row layout that reads naturally and avoids a mechanical feel.

## Layout

- The section title "I miei valori" is unchanged in style and position.
- Each value is rendered as a full-width horizontal band.
- Bands alternate background: rows 0 and 2 are transparent; rows 1 and 3 use a soft tint of `Color(0xFF1E6370)` (low opacity, e.g. `withOpacity(0.12)`).
- Content within each band is constrained to `maxWidth: 1100` and padded symmetrically (`horizontal: 24, vertical: 40`).
- No Card widget, no elevation, no border, no explicit dividers.

## Row Structure (wide screen, ≥ 600px)

- Each row is a `Row` with icon and text block as children.
- **Odd-indexed rows (0, 2):** icon on the left, text block on the right.
- **Even-indexed rows (1, 3):** icon on the right, text block on the left.
- Icon size: 68px.
- Text block: title in bold (fontSize 22, color `Color(0xFF1E6370)` on transparent rows, white on tinted rows), description below (fontSize 17, height 1.5, `Colors.black87` on transparent rows, `Colors.white70` on tinted rows). Text is left-aligned within its block.
- `SizedBox(width: 24)` gap between icon and text block.

## Responsive Collapse (< 600px)

- Icon stacks above the text block in a `Column`.
- No alternation of icon side — icon always centered above text.
- Alternating backgrounds are preserved.
- Text becomes center-aligned on mobile.

## Colors

| Context          | Title color          | description color  | Background                        |
|------------------|----------------------|--------------------|-----------------------------------|
| Transparent row  | `Color(0xFF1E6370)`  | `Colors.black87`   | transparent                       |
| Tinted row       | `Colors.white`       | `Colors.white70`   | `Color(0xFF1E6370).withOpacity(0.12)` |

## Files Affected

- `lib/pages/home_page.dart` — replace `_ValoriSection` and `_ValoreCard` classes in place.
