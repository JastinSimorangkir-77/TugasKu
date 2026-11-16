import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../services/storage_service.dart';

class ActivityNotifier extends StateNotifier<UserActivity?> {
  ActivityNotifier() : super(StorageService.loadLastActivity());

  void logActivity({
    required String title,
    required String description,
    required ActivityType type,
  }) {
    final activity = UserActivity(
      title: title,
      description: description,
      timestamp: DateTime.now(),
      type: type,
    );
    state = activity;
    StorageService.saveLastActivity(activity);
  }
}

final lastActivityProvider =
    StateNotifierProvider<ActivityNotifier, UserActivity?>((ref) {
  return ActivityNotifier();
});
