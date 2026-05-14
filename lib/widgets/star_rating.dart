import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating
              ? index < rating - 0.5
                ? Icons.star
                : Icons.star_half
              : Icons.star_border,
          size: size,
          color: Colors.amber,
        );
      }),
    );
  }
}