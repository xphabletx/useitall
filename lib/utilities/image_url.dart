// /utilities/image_url.dart

import 'package:flutter/material.dart';

Widget buildMealImage(String imageUrl, double size) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image.network(
      imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          size: size,
          color: Colors.grey,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Container(
            width: size,
            height: size,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}