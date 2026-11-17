import 'package:flutter/material.dart';

import 'app.dart';
import 'data/content_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ContentBootstrap(repository: ContentRepository()));
}
