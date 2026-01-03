class Medication {
  final int id;
  final String name;
  final String unit;
  final String defaultInstruction;

  Medication({
    required this.id,
    required this.name,
    required this.unit,
    required this.defaultInstruction
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'] ?? '',
      unit: json['unit'] ?? 'Viên',
      defaultInstruction: json['usage_instruction'] ?? '',
    );
  }
}