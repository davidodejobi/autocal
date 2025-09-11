import 'package:flutter/material.dart';

/// Extension for easy creation of SizedBox with width or height
extension NumExtension on num {
  /// Creates a SizedBox with the given width
  SizedBox get wi => SizedBox(width: toDouble());

  /// Creates a SizedBox with the given height
  SizedBox get hi => SizedBox(height: toDouble());

  /// Creates a SizedBox with both width and height
  SizedBox get wh => SizedBox(width: toDouble(), height: toDouble());
}

/// Extension on Size for more convenient SizedBox creation
extension SizedBoxExtension on Size {
  /// Creates a SizedBox with the Size's width and height
  SizedBox get wh => SizedBox(
        width: width,
        height: height,
      );
}

/// Extension on integers for displaying ordinal numbers (1st, 2nd, 3rd, etc.)
extension IntExtension on int {
  /// Converts an integer to its ordinal string representation (1st, 2nd, 3rd, etc.)
  String toOrdinal() {
    if ((this % 100) >= 11 && (this % 100) <= 13) {
      return '${this}th';
    }

    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}

/// Extension for converting numbers to words representation
extension NumberToWords on num {
  /// Converts a number to its word representation with optional currency names
  ///
  /// Example: 123.45.toWords() returns "one hundred twenty three naira and forty five kobo"
  String toWords({String currency = "naira", String subCurrency = "kobo"}) {
    // Convert the number to an integer (truncates decimals for double values)
    int wholeNumber = floor();
    int fractionalPart = ((this - wholeNumber) * 100).round();

    if (this == 0) return "zero $currency";

    final List<String> units = [
      "",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine"
    ];
    final List<String> teens = [
      "ten",
      "eleven",
      "twelve",
      "thirteen",
      "fourteen",
      "fifteen",
      "sixteen",
      "seventeen",
      "eighteen",
      "nineteen"
    ];
    final List<String> tens = [
      "",
      "",
      "twenty",
      "thirty",
      "forty",
      "fifty",
      "sixty",
      "seventy",
      "eighty",
      "ninety"
    ];
    final List<String> thousands = ["", "thousand", "million", "billion"];

    String convertThreeDigit(int num) {
      String result = "";

      if (num >= 100) {
        result += "${units[num ~/ 100]} hundred ";
        num %= 100;
      }
      if (num >= 10 && num < 20) {
        result += "${teens[num - 10]} ";
      } else if (num >= 20 || num == 10) {
        result += "${tens[num ~/ 10]} ";
        num %= 10;
      }
      if (num > 0 && num < 10) {
        result += "${units[num]} ";
      }

      return result.trim();
    }

    String convertWholeNumber(int number) {
      if (number == 0) return "";

      String result = "";
      int i = 0;

      while (number > 0) {
        int remainder = number % 1000;
        if (remainder != 0) {
          result = "${convertThreeDigit(remainder)} ${thousands[i]} $result";
        }
        number ~/= 1000;
        i++;
      }

      return result.trim();
    }

    // Convert the whole number part
    String wholeNumberWords = convertWholeNumber(wholeNumber);

    // Convert the fractional part if necessary
    String fractionalWords = fractionalPart > 0
        ? "and ${convertWholeNumber(fractionalPart)} $subCurrency"
        : "";

    return "$wholeNumberWords $currency $fractionalWords".trim();
  }
}
