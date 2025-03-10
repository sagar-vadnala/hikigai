import 'package:hive_flutter/hive_flutter.dart';

abstract class FavouritesLocalStorage {
  static const String favouritesBox = 'favouritesBox';

  static Future<Box> _getFavouritesBox() async {
    if (Hive.isBoxOpen(favouritesBox)) {
      return Hive.box(favouritesBox);
    } else {
      return await Hive.openBox(favouritesBox);
    }
  }

  static Future<void> closeFavouritesBox() async {
    if (Hive.isBoxOpen(favouritesBox)) {
      Hive.box(favouritesBox).close();
    }
  }

  static Future<void> clearAllFavourites() async {
    final box = await _getFavouritesBox();
    await box.clear();
  }

  /// Saves a product to the local storage
  static Future<void> saveFavourites(String productId) async {
    final box = await _getFavouritesBox();
    // doing this to save time, it should use a list to save the product ids
    box.put(productId, productId);
  }

  /// Delete the specified product from local storage
  static Future<void> deleteFavourites(String productId) async {
    final box = await _getFavouritesBox();
    box.delete(productId);
  }

  /// Get the full list of products
  static Future<Set<String>> getFavourites() async {
    final box = await _getFavouritesBox();
    final Set<String> result = {};
    for (final o in box.values) {
      if (o == null) {
        continue;
      }
      result.add(o);
    }
    return result;
  }
}
