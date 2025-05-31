class Exercise {
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String id;
  final String name;
  final String target;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  Exercise({
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.id,
    required this.name,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      bodyPart: json['bodyPart'] ?? '',
      equipment: json['equipment'] ?? '',
      gifUrl: json['gifUrl'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      target: json['target'] ?? '',
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}
