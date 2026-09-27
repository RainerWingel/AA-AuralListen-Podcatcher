import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Returns "now". Injected so that time-based rules (e.g. the 96 h eviction) are testable.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);
