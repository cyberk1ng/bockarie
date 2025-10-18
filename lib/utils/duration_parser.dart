/// Parses duration from Shippo API response
/// Returns a tuple of (etaMin, etaMax)
(int, int) parseDuration(int? estimatedDays, String? durationTerms) {
  // Try parsing duration_terms first
  if (durationTerms != null && durationTerms.isNotEmpty) {
    // Match patterns like "2-3 days", "2-3 business days", "Delivery in 2-3 business days"
    final rangeMatch = RegExp(r'(\d+)-(\d+)').firstMatch(durationTerms);
    if (rangeMatch != null) {
      return (int.parse(rangeMatch.group(1)!), int.parse(rangeMatch.group(2)!));
    }

    // Match single number like "5 days", "Delivery in 5 business days"
    final singleMatch = RegExp(
      r'(\d+)\s+(?:business\s+)?days?',
    ).firstMatch(durationTerms);
    if (singleMatch != null) {
      final days = int.parse(singleMatch.group(1)!);
      return (days, days + 1);
    }
  }

  // Use estimated_days
  if (estimatedDays != null && estimatedDays > 0) {
    // Create a range: estimatedDays to estimatedDays + 1
    return (estimatedDays, estimatedDays + 1);
  }

  // Fallback to default
  return (5, 7);
}
