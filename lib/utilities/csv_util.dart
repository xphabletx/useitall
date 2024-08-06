import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/meal.dart';

Future<List<Meal>> loadMealsFromCsv() async {
  final data = await rootBundle.loadString('assets/recipes.csv');
  List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
  return csvTable.map((row) => Meal.fromCsv(row)).toList();
}