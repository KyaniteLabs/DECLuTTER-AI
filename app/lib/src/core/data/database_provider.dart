import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

/// Global access point for the local Drift database.
///
/// In a larger app this would be injected via Provider or GetIt.
/// For the MVP, a lazy singleton keeps the surface area small.
class DatabaseProvider {
  DatabaseProvider._();

  static AppDatabase? _instance;

  static AppDatabase get instance {
    _instance ??= AppDatabase(
      driftDatabase(name: 'declutter_ai_db'),
    );
    return _instance!;
  }

  static void dispose() {
    _instance?.close();
    _instance = null;
  }
}
