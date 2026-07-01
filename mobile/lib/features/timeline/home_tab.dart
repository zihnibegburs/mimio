import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeTab { today, week, focus }

final homeTabProvider = StateProvider<HomeTab>((ref) => HomeTab.today);
