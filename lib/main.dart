import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'src/core/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    UncontrolledProviderScope(
      container: await bootstrap(),
      child: const MyApp(),
    ),
  );
}
