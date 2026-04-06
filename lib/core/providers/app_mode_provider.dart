import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppMode { budget, pantry }

final StateProvider<AppMode> appModeProvider = StateProvider<AppMode>(
  (Ref ref) => AppMode.budget,
);
