import 'dart:io';

import 'package:csv/csv.dart';

void main() {
  final file = File('docs/barkod_listesi_mock.csv');
  final content = file.readAsStringSync();
  final rows = Csv().decode(content);
  stdout.writeln('Total rows: ${rows.length}');
  int bad = 0;
  for (var i = 0; i < rows.length; i++) {
    if (rows[i].length != 8) {
      bad++;
      if (bad <= 10) {
        stdout.writeln('Row ${i + 1} length ${rows[i].length}: ${rows[i]}');
      }
    }
  }
  stdout.writeln('Bad rows: $bad');
}
