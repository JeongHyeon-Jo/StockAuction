import 'package:flutter/material.dart';

class FavoriteButtonWidget extends StatelessWidget {
  final String postUid;
  final bool isFavorited;
  final VoidCallback onPressed;
  final double padding;

  const FavoriteButtonWidget({
    Key? key,
    required this.postUid,
    required this.isFavorited,
    required this.onPressed,
    this.padding = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        color: isFavorited ? Colors.red : null,
      ),
      padding: EdgeInsets.all(padding),
      onPressed: onPressed,
    );
  }
}