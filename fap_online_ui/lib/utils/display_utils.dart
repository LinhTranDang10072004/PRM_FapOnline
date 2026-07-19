String displayText(String? value, {String fallback = '-'}) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

String formatMoney(num? value) {
  if (value == null) return '-';
  final raw = value.toStringAsFixed(value is int ? 0 : 2);
  final parts = raw.split('.');
  final whole = parts.first;
  final decimal = parts.length > 1 ? '.${parts.last}' : '';
  final reversed = whole.split('').reversed.join();
  final groups = <String>[];
  for (var i = 0; i < reversed.length; i += 3) {
    final end = i + 3;
    groups.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
  }
  final formattedWhole = groups.map((group) => group.split('').reversed.join()).toList().reversed.join(',');
  return '$formattedWhole$decimal';
}

String formatDateLabel(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return '-';
  final normalized = text.replaceFirst('T', ' ');
  if (normalized.length >= 10) {
    final date = normalized.substring(0, 10);
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
  }
  return text;
}

String formatDateTimeLabel(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return '-';
  final normalized = text.replaceFirst('T', ' ');
  if (normalized.length >= 16) {
    final date = normalized.substring(0, 10);
    final time = normalized.substring(11, 16);
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]} $time';
    }
  }
  return text;
}
