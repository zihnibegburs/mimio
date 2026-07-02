import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeTab { today, week, focus, achievements }

final homeTabProvider = StateProvider<HomeTab>((ref) => HomeTab.today);
