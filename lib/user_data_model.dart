class User {
  final String name;
  final String registrationNumber;
  final double mark1;
  final double mark2;
  final double mark3;

  User({
    required this.name,
    required this.registrationNumber,
    required this.mark1,
    required this.mark2,
    required this.mark3,
  });

  double get total => mark1 + mark2 + mark3;
  double get average => total / 3;
  double get percentage => (total / 300) * 100;
}