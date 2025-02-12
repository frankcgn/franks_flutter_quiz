// utilities.dart
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

DateTime parseDate(String dateStr) {
  final parts = dateStr.split('.');
  return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}