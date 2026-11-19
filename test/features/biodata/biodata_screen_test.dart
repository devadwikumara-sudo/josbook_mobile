import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/features/biodata/biodata_model.dart';
import 'package:josbook_mobile/features/biodata/biodata_screen.dart';
import 'package:josbook_mobile/features/biodata/biodata_service.dart';

void main() {
  testWidgets('shows service biodata instead of local sample values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BiodataScreen(service: _BiodataService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Siswa dari API'), findsOneWidget);
    expect(find.text('0012345678'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Indra Kusuma'), findsNothing);
  });
}

class _BiodataService extends BiodataService {
  @override
  Future<BiodataData> ambil() async => const BiodataData(
    nama: 'Siswa dari API',
    nisn: '0012345678',
    nomorInduk: '9001',
  );
}
