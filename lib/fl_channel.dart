library fl_channel;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/event.dart';

part 'src/basic_message.dart';

class FlChannel {
  factory FlChannel() => _singleton ??= FlChannel._();

  FlChannel._();

  static FlChannel? _singleton;

  final MethodChannel _channel = const MethodChannel('fl_channel');
}

bool get _supportPlatform {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}
