import 'package:flutter/material.dart';

import '../../models/recipe.dart';

class RecipeContent extends StatelessWidget {
  final List<Recipe> recipes;
  const RecipeContent({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No recipe information available')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children:
            recipes.map((recipe) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading:
                      recipe.logo != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(recipe.logo!),
                            backgroundColor: Colors.transparent,
                          )
                          : const CircleAvatar(
                            child: Icon(Icons.restaurant_menu),
                          ),
                  title: Text(
                    recipe.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(recipe.description),
                        ),
                      if (recipe.ingredients.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Ingredients: ${recipe.ingredients}'),
                        ),
                      if (recipe.linkType.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Link Type: ${recipe.linkType}'),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
