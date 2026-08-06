import 'package:barkod_hub/core/di/service_locator.dart';
import 'package:barkod_hub/core/services/error_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ErrorTracker logs API, Camera, Download and Unhandled errors', () async {
    await ErrorTracker.trackApiError('Timeout 404');
    await ErrorTracker.trackCameraError('Permission denied');
    await ErrorTracker.trackDownloadError('Storage full');
    await ErrorTracker.trackUnhandledError(
      Exception('Crash test'),
      StackTrace.current,
    );

    final logs = await ServiceLocator.logService.getLogs();
    expect(logs, hasLength(4));

    final tags = logs.map((l) => l.tag).toList();
    expect(tags, containsAll(['API', 'CAMERA', 'DOWNLOAD', 'CRASH']));
  });
}
