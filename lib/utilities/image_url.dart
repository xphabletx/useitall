import 'package:flutter/material.dart';

Widget buildMealImage(String imageUrl, bool isExpanded) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: isExpanded ? 200 : 50,
    height: isExpanded ? 200 : 50,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image,
            size: isExpanded ? 200 : 50,
            color: Colors.grey,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return SizedBox(
              width: isExpanded ? 200 : 50,
              height: isExpanded ? 200 : 50,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    ),
  );
}