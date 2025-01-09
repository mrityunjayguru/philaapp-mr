
  enum LanguageState {
  downloaded,
  startTour,
  noLangSelected
  }

  enum ShowIcon { NO, YES }

  final showIconValues = EnumValues({"no": ShowIcon.NO, "yes": ShowIcon.YES});


  enum Status { ACTIVE }

  final statusValues = EnumValues({"active": Status.ACTIVE});

  class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
      reverseMap = map.map((k, v) => MapEntry(v, k));
      return reverseMap;
    }
  }
