import 'dart:convert';

import 'package:city_sightseeing/model/places_list_model.dart';
import 'package:city_sightseeing/service/shared_pred_service.dart';
import 'package:flutter/material.dart';

class FavoriteService with ChangeNotifier {
  List<PlacesListData> favPlaces = [];
  SharedPrefService favService = new SharedPrefService();

  addFav(PlacesListData item) {
    favPlaces.add(item);
    notifyListeners();
    updateInLocalStorage();
  }

  Future updateInLocalStorage() async {
    String fav = jsonEncode(favPlaces);
    await favService.setFavList(fav);
  }

  Future getInLocalStorage() async {
    try {
      // var fav = await favService.removeFavList();
      var fav = await favService.getFavList();

      var data = jsonDecode(fav!) as List;
      favPlaces = [];
      data.forEach((ele) {
        favPlaces.add(PlacesListData.fromJson(ele));
      });

      notifyListeners();
    } catch (e) {
      debugPrint("favorite ===== > $e");
    }
  }

  removeFromFavList(String id) {
    favPlaces.removeWhere((e) => e.id.toString() == id);
    notifyListeners();
  }
}
