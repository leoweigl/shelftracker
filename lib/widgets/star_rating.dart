import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final startWidth = size + 4;
    final isInteractive = onRatingChanged != null;

    void updateRating(double localX) {
      final raw = (localX / startWidth) * 2;
      final newRating = (raw.round() / 2).clamp(0.0, 5.0);
      onRatingChanged!(newRating);
    }

    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return SizedBox(
          width: startWidth,
          child: Icon(
            index < rating
                ? index < rating - 0.5
                  ? Icons.star
                  : Icons.star_half
                : Icons.star_border,
            size: size,
            color: Colors.amber,
          ),
        );
      }),
    );

    if (!isInteractive) {
      return stars;
    }

    return GestureDetector(
      onTapDown: (details) => updateRating(details.localPosition.dx),
      onHorizontalDragUpdate: (details) => updateRating(details.localPosition.dx),
      child: stars,
    );
  }
}