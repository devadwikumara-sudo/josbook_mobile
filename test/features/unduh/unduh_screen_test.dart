import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/features/nilai/nilai_model.dart';
import 'package:josbook_mobile/features/nilai/nilai_service.dart';
import 'package:josbook_mobile/features/unduh/unduh_screen.dart';
import 'package:josbook_mobile/features/unduh/unduh_service.dart';

void main() {
  testWidgets('uses only completed API periods for download selections', (
    tester,
  ) async {
    final periodeService = _FakeNilaiService([
      const NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
      const NilaiPeriode(tahunAjaran: '2024/2025', semester: 'Genap'),
    ]);
    final unduhService = _FakeUnduhService();

    await tester.pumpWidget(_app(periodeService, unduhService));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nilai').first);
    await tester.pumpAndSettle();
    expect(find.text('2025/2026'), findsOneWidget);
    expect(find.text('Ganjil'), findsOneWidget);
    expect(find.text('Genap'), findsNothing);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024/2025').last);
    await tester.pumpAndSettle();

    expect(find.text('Genap'), findsOneWidget);
    expect(find.text('Ganjil'), findsNothing);
    await tester.tap(find.text('Unduh PDF'));
    await tester.pumpAndSettle();

    expect(unduhService.jenis, JenisUnduhan.nilai);
    expect(unduhService.tahunAjaran, '2024/2025');
    expect(unduhService.semester, 'Genap');
  });

  testWidgets('Biodata downloads without period selections or parameters', (
    tester,
  ) async {
    final unduhService = _FakeUnduhService();

    await tester.pumpWidget(_app(_FakeNilaiService(const []), unduhService));
    await tester.pumpAndSettle();

    expect(find.text('2025/2026'), findsNothing);
    expect(find.text('Ganjil'), findsNothing);
    expect(find.text('Genap'), findsNothing);

    await tester.tap(find.text('Unduh PDF'));
    await tester.pumpAndSettle();

    expect(unduhService.jenis, JenisUnduhan.biodata);
    expect(unduhService.tahunAjaran, isNull);
    expect(unduhService.semester, isNull);
  });
}

Widget _app(NilaiService periodeService, UnduhService unduhService) {
  return MaterialApp(
    home: UnduhScreen(periodeService: periodeService, service: unduhService),
  );
}

class _FakeNilaiService implements NilaiService {
  const _FakeNilaiService(this.periode);

  final List<NilaiPeriode> periode;

  @override
  Future<List<NilaiPeriode>> ambilPeriode() async => periode;

  @override
  Future<NilaiData> ambilNilai(NilaiPeriode periode) {
    throw UnimplementedError();
  }
}

class _FakeUnduhService extends UnduhService {
  JenisUnduhan? jenis;
  String? tahunAjaran;
  String? semester;

  @override
  Future<void> unduh({
    required JenisUnduhan jenis,
    String? tahunAjaran,
    String? semester,
  }) async {
    this.jenis = jenis;
    this.tahunAjaran = tahunAjaran;
    this.semester = semester;
  }
}
