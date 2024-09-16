import 'package:flutter/material.dart';

extension StringOverflow on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();
  String get removePTELines =>
      replaceAll(RegExp(r'^\s*\n+|\n+\s*$'), '').trim();

  String get trimWhiteSpaces {
    return trim().split(RegExp(r'^(?!\n$)')).join('');
  }
}
