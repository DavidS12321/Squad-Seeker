class Game {
  String name;
  String skillLevel;
  String playStyle;

  Game({
    required this.name,
    required this.skillLevel,
    required this.playStyle,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'skillLevel': skillLevel,
      'playStyle': playStyle,
    };
  }

  static Game fromMap(Map<String, dynamic> map) {
    return Game(
      name: map['name'],
      skillLevel: map['skillLevel'],
      playStyle: map['playStyle'],
    );
  }
}