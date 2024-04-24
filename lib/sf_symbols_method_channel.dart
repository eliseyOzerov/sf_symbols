import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sf_symbols_platform_interface.dart';

/// An implementation of [SfSymbolsPlatform] that uses method channels.
class MethodChannelSfSymbols extends SfSymbolsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sf_symbols');

  static const idKey = "textureId";

  @override
  Future<(int, Size)?> init({
    required String name,
    required FontWeight weight,
    required Color color,
    required double size,
  }) async {
    final hexColor = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();

    try {
      final result = await methodChannel.invokeMethod('init', {
        'name': name,
        'weight': weight.index + 1,
        'color': '#$hexColor',
        'size': size,
      });

      final textureId = result[idKey] as int;
      final sizeRes = Size(result["size"]["width"] as double, result["size"]["height"] as double);

      return (textureId, sizeRes);
    } catch (e) {
      if (kDebugMode) print('SfSymbols init: $e');
      return null;
    }
  }

  @override
  Future dispose(int textureId) async {
    try {
      await methodChannel.invokeMethod('dispose', {
        idKey: textureId,
      });
    } catch (e) {
      if (kDebugMode) print('SfSymbols dispose: $e');
    }
  }
}
