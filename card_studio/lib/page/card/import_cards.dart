import 'package:homeprint_o_tool/core/card.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class DecodedCardName {
  final String path;
  final String name;
  final int amount;
  final bool backside;
  DecodedCardName(this.path, this.name, this.amount, this.backside);
}

final eligibleFrontSuffixes = [
  '-A',
  '-a',
  '-Front',
  '-front',
  '_A',
  '_a',
  '_Front',
  '_front',
  '-1',
];

final eligibleBackSuffixes = [
  '-B',
  '-b',
  '-Back',
  '-back',
  '_B',
  '_b',
  '_Back',
  '_back',
  '-2',
];

bool isFront(String name) {
  return eligibleFrontSuffixes.any((element) => name.endsWith(element));
}

DecodedCardName decodeCardName(String path) {
  var amount = 1;
  var backside = false;
  var name = path;
  // Remove extension
  final dotPosition = name.lastIndexOf('.');
  if (dotPosition == -1) {
    throw Exception('No extension found in $path');
  }
  name = name.substring(0, dotPosition);

  // Strip out front/back suffix
  for (var suffix in eligibleBackSuffixes) {
    if (name.endsWith(suffix)) {
      name = name.substring(0, name.length - suffix.length);
      backside = true;
      break;
    }
  }
  if (!backside) {
    for (var suffix in eligibleFrontSuffixes) {
      if (name.endsWith(suffix)) {
        name = name.substring(0, name.length - suffix.length);
        break;
      }
    }
  }
  // Extract a card count preceded by -x before the front/back flag, e.g. -x2-front
  final match = RegExp(r'-x(\d+)').firstMatch(name);
  if (match != null) {
    amount = int.parse(match.group(1)!);
    name = name.substring(0, match.start);
  }
  final justFileName = basename(name);
  return DecodedCardName(path, justFileName, amount, backside);
}

List<DuplexCard> importCards(
    List<String> paths, CardFace? missingFaceReplacement) {
  final map = <String, DuplexCard>{};
  for (var path in paths) {
    final decoded = decodeCardName(path);
    final relativePath = decoded.path;
    final decodedCardFace = CardFace(relativePath, Alignment.center, 1.0,
        Rotation.none, decoded.name, true, true, true, false);
    map.update(decoded.name, (card) {
      card.amount = decoded.amount;
      if (decoded.backside) {
        card.back = decodedCardFace;
      } else {
        card.front = decodedCardFace;
      }
      return card;
    }, ifAbsent: () {
      if (decoded.backside) {
        return DuplexCard(missingFaceReplacement, decodedCardFace,
            decoded.amount, decoded.name);
      } else {
        return DuplexCard(decodedCardFace, missingFaceReplacement,
            decoded.amount, decoded.name);
      }
    });
  }
  return map.values.toList();
}
