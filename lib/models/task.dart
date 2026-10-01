class Task {
  final String title;
  final DateTime date;

  Task({
    required this.title,
    required this.date, required String description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']), description: '',
    );
  }

  String? get description => null;
}