import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/product/models/product_model.dart';

class FavoritesService {
  FavoritesService({Future<SharedPreferences>? preferences})
      : _preferences = preferences ?? SharedPreferences.getInstance();

  final Future<SharedPreferences> _preferences;

  static const String _favoritesKey = 'cache_user_favorites';

  Future<List<ProductModel>> getFavorites() async {
    final prefs = await _preferences;
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.map((item) {
      final json = jsonDecode(item) as Map<String, dynamic>;
      return ProductModel.fromJson(json);
    }).toList();
  }

  Future<bool> isFavorite(String? barcode) async {
    if (barcode == null || barcode.isEmpty) return false;
    final favorites = await getFavorites();
    return favorites.any((p) => p.barcode == barcode);
  }

  Future<bool> toggleFavorite(ProductModel product) async {
    if (product.barcode == null || product.barcode!.isEmpty) return false;

    final prefs = await _preferences;
    final favorites = await getFavorites();
    final index = favorites.indexWhere((p) => p.barcode == product.barcode);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(product);
    }

    final rawList = favorites.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_favoritesKey, rawList);
    return index < 0; // returns true if newly added to favorites
  }

  Future<void> removeFavorite(String barcode) async {
    if (barcode.isEmpty) return;

    final prefs = await _preferences;
    final favorites = await getFavorites();
    favorites.removeWhere((p) => p.barcode == barcode);

    final rawList = favorites.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_favoritesKey, rawList);
  }
}
