import 'package:card_studio/core/card.dart';
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
  '-1',
];

final eligibleBackSuffixes = [
  '-B',
  '-b',
  '-Back',
  '-back',
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

List<CardEach> importCards(
    List<String> paths, CardEachSingle? missingSideInstance) {
  final map = <String, CardEach>{};
  for (var path in paths) {
    final decoded = decodeCardName(path);
    final decodedCardEachSingle = CardEachSingle(
        path,
        Alignment.center,
        1.0,
        Rotation.none,
        PerCardSynthesizedBleed.mirror,
        decoded.name,
        true,
        true,
        true,
        false);
    map.update(decoded.name, (card) {
      card.amount = decoded.amount;
      if (decoded.backside) {
        card.back = decodedCardEachSingle;
      } else {
        card.front = decodedCardEachSingle;
      }
      return card;
    }, ifAbsent: () {
      if (decoded.backside) {
        return CardEach(missingSideInstance, decodedCardEachSingle,
            decoded.amount, decoded.name);
      } else {
        return CardEach(decodedCardEachSingle, missingSideInstance,
            decoded.amount, decoded.name);
      }
    });
  }
  return map.values.toList();
}
