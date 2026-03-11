import 'dart:math';

/// Generates invite codes in format: 4 uppercase letters + 4 numbers (e.g. FISH4821).
String generateInviteCode() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  final random = Random();
  final letterPart = List.generate(4, (_) => letters[random.nextInt(letters.length)]).join();
  final numberPart = List.generate(4, (_) => numbers[random.nextInt(numbers.length)]).join();
  return '$letterPart$numberPart';
}
