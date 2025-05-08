import 'package:flutter/material.dart';

enum Rotation {
  none,
  clockwise90,
  counterClockwise90,
}

Alignment alignmentFromJson(Map<String, dynamic> json) {
  // if int, cast to double
  final double x = jsonToDouble(json['x']);
  final double y = jsonToDouble(json['y']);
  return Alignment(x, y);
}

double jsonToDouble(dynamic json) {
  if (json is int) {
    return json.toDouble();
  } else if (json is double) {
    return json;
  } else {
    throw Exception("Invalid alignment x value: $json");
  }
}

bool jsonToBoolOrFalse(dynamic json) {
  if (json is bool) {
    return json;
  }
  return false;
}

bool jsonToBoolOrTrue(dynamic json) {
  if (json is bool) {
    return json;
  }
  return true;
}

Map<String, dynamic> alignmentToJson(Alignment alignment) {
  return {
    'x': alignment.x,
    'y': alignment.y,
  };
}
