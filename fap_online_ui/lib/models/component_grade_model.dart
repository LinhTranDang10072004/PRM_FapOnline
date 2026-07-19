class ComponentGradeModel {
  final String componentName;
  final double weight;
  final double? score;

  ComponentGradeModel({
    required this.componentName,
    required this.weight,
    this.score,
  });

  factory ComponentGradeModel.fromJson(Map<String, dynamic> json) {
    return ComponentGradeModel(
      componentName: json['componentName'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      score: (json['score'] as num?)?.toDouble(),
    );
  }
}
