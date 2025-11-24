import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import 'category_meals_screen.dart';
import 'meal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _all = [];
  List<Category> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    try {
      final cats = await ApiService.fetchCategories();
      setState(() {
        _all = cats;
        _filtered = cats;
      });
    } catch (e) {
      // handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Грешка при преземање категории')));
    } finally {
      setState(() { _loading = false; });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _query = q;
      _filtered = _all.where((c) => c.strCategory.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  Future<void> _openRandom() async {
    try {
      final meal = await ApiService.fetchRandomMeal();
      Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.idMeal)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Не можев да преземам рандом рецепт')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Рецепти - Категории'),
        actions: [
          IconButton(
            tooltip: 'Рандом рецепт',
            icon: Icon(Icons.shuffle),
            onPressed: _openRandom,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Пребарај категории',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                    mainAxisExtent: 260,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, idx) {
                    final cat = _filtered[idx];
                    return CategoryCard(
                      category: cat,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CategoryMealsScreen(category: cat.strCategory),
                        ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
