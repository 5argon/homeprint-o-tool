import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homeprint_o_tool/page/layout/layout_data.dart';
import 'package:homeprint_o_tool/page/layout/back_arrangement.dart';
import 'package:homeprint_o_tool/core/json.dart';

class LayoutStorage {
  static const String _layoutDataKey = 'layout_data';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<void> saveLayoutData(LayoutData layoutData) async {
    final jsonString = jsonEncode(layoutData.toJson());
    await _prefs.setString(_layoutDataKey, jsonString);
  }

  static Future<LayoutData?> loadLayoutData() async {
    final jsonString = await _prefs.getString(_layoutDataKey);

    if (jsonString == null) {
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LayoutData.fromJson(json);
    } catch (e) {
      print('Error loading layout data: $e');
      return null;
    }
  }

  static Future<void> clearLayoutData() async {
    await _prefs.remove(_layoutDataKey);
  }

  static LayoutData getDefaultLayoutData() {
    return LayoutData(
      paperSize: SizePhysical(21, 29.7, PhysicalSizeType.centimeter),
      marginSize: SizePhysical(0.25, 0.25, PhysicalSizeType.inch),
      edgeCutGuideSize: SizePhysical(0.5, 0.5, PhysicalSizeType.centimeter),
      backArrangement: BackArrangement.invertedRow,
      skips: [],
      removeOneColumn: false,
      removeOneRow: false,
      frontPostRotation: Rotation.none,
      backPostRotation: Rotation.none,
      bleedSettings: BleedSettings.default_,
      generatedBleedPercentage: 0.75,
      collapseGaps: false,
    );
  }
}
