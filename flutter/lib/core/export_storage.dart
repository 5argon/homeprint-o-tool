import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homeprint_o_tool/core/page_preview/export_dialog.dart';
import 'package:homeprint_o_tool/core/page_preview/cut_guide_style.dart';
import 'package:homeprint_o_tool/core/json.dart';

class ExportStorage {
  static const String _exportSettingsKey = 'export_settings';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<void> saveExportSettings(ExportSettings settings) async {
    final jsonString = jsonEncode(_exportSettingsToJson(settings));
    await _prefs.setString(_exportSettingsKey, jsonString);
  }

  static Future<ExportSettings?> loadExportSettings() async {
    final jsonString = await _prefs.getString(_exportSettingsKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return _exportSettingsFromJson(json);
    } catch (e) {
      print('Error loading export settings: $e');
      return null;
    }
  }

  static Future<void> clearExportSettings() async {
    await _prefs.remove(_exportSettingsKey);
  }

  static ExportSettings getDefaultExportSettings() {
    return ExportSettings(
      prefix: 'export',
      template: '{prefix}_{page}_{side}',
      frontSuffix: 'A',
      backSuffix: 'B',
      frontRotation: Rotation.none,
      backRotation: Rotation.none,
      frontSideOnly: false,
      pixelPerInch: 300,
      cutGuideStyle: CutGuideStyle.none,
    );
  }

  static Map<String, dynamic> _exportSettingsToJson(ExportSettings settings) {
    return {
      'prefix': settings.prefix,
      'template': settings.template,
      'frontSuffix': settings.frontSuffix,
      'backSuffix': settings.backSuffix,
      'frontRotation': settings.frontRotation.index,
      'backRotation': settings.backRotation.index,
      'frontSideOnly': settings.frontSideOnly,
      'pixelPerInch': settings.pixelPerInch,
      'cutGuideStyle': settings.cutGuideStyle.index,
    };
  }

  static ExportSettings _exportSettingsFromJson(Map<String, dynamic> json) {
    return ExportSettings(
      prefix: json['prefix'] as String? ?? 'export',
      template: json['template'] as String? ?? '{prefix}_{page}_{side}',
      frontSuffix: json['frontSuffix'] as String? ?? 'A',
      backSuffix: json['backSuffix'] as String? ?? 'B',
      frontRotation: Rotation.values[json['frontRotation'] as int? ?? 0],
      backRotation: Rotation.values[json['backRotation'] as int? ?? 0],
      frontSideOnly: json['frontSideOnly'] as bool? ?? false,
      pixelPerInch: json['pixelPerInch'] as int? ?? 300,
      cutGuideStyle: CutGuideStyle.values[json['cutGuideStyle'] as int? ?? 0],
    );
  }
}
