
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/pages/editor/editor.dart';

class EditorCoreInfo {
  static const int fileVersion = 2;

  static const double defaultWidth = 1000;
  static const double defaultHeight = defaultWidth * 1.4;

  final List<Stroke> strokes;
  Color? backgroundColor;
  final double width;
  final double height;

  EditorCoreInfo({
    List<Stroke>? strokes,
    this.backgroundColor,
    this.width = defaultWidth,
    this.height = defaultHeight,
  }): strokes = strokes ?? [];

  EditorCoreInfo.fromJson(Map<String, dynamic> json):
        strokes = _parseStrokesJson(json["s"] as List),
        backgroundColor = json["b"] != null ? Color(json["b"] as int) : null,
        width = json["w"] ?? defaultWidth,
        height = json["h"] ?? defaultHeight;
  EditorCoreInfo.fromOldJson(List<dynamic> json):
        strokes = _parseStrokesJson(json),
        width = defaultWidth,
        height = defaultHeight;

  static List<Stroke> _parseStrokesJson(List<dynamic> strokes) => strokes
      .map((dynamic stroke) => Stroke.fromJson(stroke as Map<String, dynamic>))
      .toList();

  static Future<EditorCoreInfo> loadFromFilePath(String path) async {
    String? jsonString = await FileManager.readFile(path + Editor.extension);
    if (jsonString == null) return EditorCoreInfo();

    try {
      final dynamic json = jsonDecode(jsonString);
      if (json is List) { // old format
        return EditorCoreInfo.fromOldJson(json);
      } else {
        return EditorCoreInfo.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        rethrow;
      } else {
        return EditorCoreInfo();
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'v': fileVersion,
    's': strokes,
    'b': backgroundColor?.value,
    'w': width,
    'h': height,
  };

  EditorCoreInfo copyWith({
    List<Stroke>? strokes,
    Color? backgroundColor,
    double? width,
    double? height,
  }) {
    return EditorCoreInfo(
      strokes: strokes ?? this.strokes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
