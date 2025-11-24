import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import '../widgets/ingredient_row.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({required this.mealId});

  @override
  _MealDetailScreenState createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealDetail? _meal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  Future<void> _loadMeal() async {
    setState(() => _loading = true);
    try {
      final detail = await ApiService.fetchMealDetail(widget.mealId);
      setState(() => _meal = detail);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка при преземање на рецепт')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не можам да отворам YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meal?.strMeal ?? 'Рецепт'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _meal == null
          ? Center(child: Text('Нема податоци'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rounded image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _meal!.strMealThumb + '/preview',
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            // Meal title
            Text(
              _meal!.strMeal,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Category & Area
            Text(
              '${_meal!.strCategory} • ${_meal!.strArea}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),

            // Instructions
            Text(
              'Инструкции',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 6),
            Text(_meal!.strInstructions),
            SizedBox(height: 16),

            // Ingredients using IngredientRow
            Text(
              'Состојки',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 6),
            ..._meal!.ingredients.entries
                .map((e) => IngredientRow(
              ingredient: e.key,
              measure: e.value,
            ))
                .toList(),

            SizedBox(height: 16),

            // YouTube button with extra space
            if (_meal!.strYoutube != null &&
                _meal!.strYoutube!.isNotEmpty)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openYoutube(_meal!.strYoutube!),
                    icon: Icon(Icons.play_circle_fill),
                    label: Text('Отвори YouTube'),
                  ),
                  SizedBox(height: 24), // extra spacing
                ],
              ),
          ],
        ),
      ),
    );
  }
}
