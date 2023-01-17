export 'dart:async';
export 'dart:io';
export 'dart:ui';
export 'package:flutter/services.dart';
export 'package:connectivity/connectivity.dart';
export 'package:cobiz_client/config/app_styles.dart';
export 'package:cobiz_client/config/keys.dart';
export 'package:cobiz_client/config/storage_manager.dart';
export 'package:cobiz_client/tools/shared_util.dart';
export 'package:cobiz_client/tools/common_util.dart';
export 'package:cobiz_client/tools/check.dart';
export 'package:cobiz_client/tools/event_bus.dart';
export 'package:cobiz_client/tools/my_behavior.dart';
export 'package:cobiz_client/tools/route.dart';
export 'package:cobiz_client/tools/win_media.dart';
export 'package:cobiz_client/tools/screen.dart';
export 'package:cobiz_client/generated/l10n.dart';
export 'package:provider/provider.dart';
export 'package:cobiz_client/provider/global_model.dart';
export 'package:cobiz_client/provider/theme_model.dart';
export 'package:cobiz_client/ui/view/image_view.dart';
export 'package:cobiz_client/ui/view/operate_line_view.dart';
export 'package:cobiz_client/ui/view/list_item_view.dart';
export 'package:cobiz_client/ui/dialog/show_toast.dart';
export 'package:cobiz_client/ui/appbar/commom_appbar.dart';
export 'package:cobiz_client/tools/common_widget.dart';
export 'package:cobiz_client/ui/picker/data_picker.dart';
export 'package:cobiz_client/ui/dialog/confirm_alert.dart';
export 'package:cobiz_client/ui/dialog/loading_dialog.dart';
export 'package:cobiz_client/tools/utils/vibration.dart';
export 'package:cobiz_client/tools/permission_handle.dart';
export 'package:permission_handler/permission_handler.dart';

import 'package:connectivity/connectivity.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

var subscription = Connectivity();

typedef Callback(data);

DefaultCacheManager cacheManager = new DefaultCacheManager();
