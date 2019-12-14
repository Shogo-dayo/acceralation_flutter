class UserRegist{
  final String name;
  final int x;
  final int y;
  final int step;

  UserRegist({this.name, this.x, this.y, this.step});

  factory UserRegist.fromJson(Map<String, dynamic> json) {
    return UserRegist(
      name: json['name'],
      x: json['x'],
      y: json['y'],
      step: json['step'],
    );
  }
}