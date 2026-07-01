import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mimio/core/config/platform_config.dart';
import 'package:mimio/core/platform/widget_sync_service.dart';

class SiriSyncService {
  static const authTokenKey = 'auth_token';
  static const apiBaseUrlKey = 'api_base_url';

  static Future<void> syncCredentials({String? token}) async {
    if (kIsWeb || !WidgetSyncService.isAvailable) return;
    try {
      await HomeWidget.saveWidgetData<String>(
        apiBaseUrlKey,
        PlatformConfig.apiBaseUrl,
      );
      if (token != null && token.isNotEmpty) {
        await HomeWidget.saveWidgetData<String>(authTokenKey, token);
      } else {
        await HomeWidget.saveWidgetData<String>(authTokenKey, '');
      }
    } catch (e) {
      debugPrint('Siri sync skipped: $e');
    }
  }
}
