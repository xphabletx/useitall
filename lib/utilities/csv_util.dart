import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/meal.dart';

// Function to load meals from CSV
Future<List<Meal>> loadMealsFromCsv() async {
  final data = await rootBundle.loadString('assets/recipes.csv');
  List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
  return csvTable.skip(1).map((row) => Meal.fromCsv(row)).toList(); // Skip header row
}

// Function to load ingredient macros from CSV
Future<List<Map<String, dynamic>>> loadIngredientMacrosFromCsv() async {
  final data = await rootBundle.loadString('assets/ingredient_category_macros.csv');
  List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

  return csvTable.skip(1).map((row) {
    return {
      'ingredient_name': row[1].toString().trim(), // Column B
      'macro_category': row[4].toString().trim(), // Column E
    };
  }).toList();
}