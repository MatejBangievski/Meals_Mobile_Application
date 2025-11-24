import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const String _base = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Category>> fetchCategories() async {
    final resp = await http.get(Uri.parse('$_base/categories.php'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List categories = data['categories'] ?? [];
      return categories.map((c) => Category.fromJson(c)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final encoded = Uri.encodeComponent(category);
    final resp = await http.get(Uri.parse('$_base/filter.php?c=$encoded'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List meals = data['meals'] ?? [];
      return meals.map((m) => MealSummary.fromJson(m)).toList();
    } else {
      throw Exception('Failed to load meals for category');
    }
  }

  static Future<List<MealSummary>> searchMeals(String query) async {
    final encoded = Uri.encodeComponent(query);
    final resp = await http.get(Uri.parse('$_base/search.php?s=$encoded'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List? meals = data['meals'];
      if (meals == null) return [];
      return meals.map((m) => MealSummary.fromJson(m)).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  static Future<MealDetail> fetchMealDetail(String id) async {
    final resp = await http.get(Uri.parse('$_base/lookup.php?i=$id'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List meals = data['meals'] ?? [];
      if (meals.isEmpty) throw Exception('Meal not found');
      return MealDetail.fromJson(meals[0]);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  static Future<MealDetail> fetchRandomMeal() async {
    final resp = await http.get(Uri.parse('$_base/random.php'));
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final List meals = data['meals'] ?? [];
      if (meals.isEmpty) throw Exception('No random meal');
      return MealDetail.fromJson(meals[0]);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
