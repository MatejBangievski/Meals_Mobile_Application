import 'package:flutter/material.dart';

class IngredientRow extends StatelessWidget {
  final String ingredient;
  final String measure;

  const IngredientRow({required this.ingredient, required this.measure});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(ingredient[0].toUpperCase())),
      title: Text(ingredient),
      subtitle: Text(measure),
    );
  }
}
