class Profile {
  int? id;
  String name;
  String ageGroup;
  String icon;
  List<String> dietPreferences;
  List<String> allergies;
  bool isMain;

  Profile({
    this.id,
    required this.name,
    required this.ageGroup,
    required this.icon,
    required this.dietPreferences,
    required this.allergies,
    required this.isMain,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ageGroup': ageGroup,
      'icon': icon,
      'dietPreferences': dietPreferences.join(','),
      'allergies': allergies.join(','),
      'isMain': isMain ? 1 : 0,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      ageGroup: map['ageGroup'],
      icon: map['icon'],
      dietPreferences: (map['dietPreferences'] as String).split(','),
      allergies: (map['allergies'] as String).split(','),
      isMain: map['isMain'] == 1,
    );
  }

  Profile copyWith({
    int? id,
    String? name,
    String? ageGroup,
    String? icon,
    List<String>? dietPreferences,
    List<String>? allergies,
    bool? isMain,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      ageGroup: ageGroup ?? this.ageGroup,
      icon: icon ?? this.icon,
      dietPreferences: dietPreferences ?? this.dietPreferences,
      allergies: allergies ?? this.allergies,
      isMain: isMain ?? this.isMain,
    );
  }
}