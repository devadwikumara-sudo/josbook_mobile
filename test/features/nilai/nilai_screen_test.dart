import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josbook_mobile/features/nilai/nilai_model.dart';
import 'package:josbook_mobile/features/nilai/nilai_screen.dart';
import 'package:josbook_mobile/features/nilai/nilai_service.dart';
import 'package:josbook_mobile/features/unduh/unduh_service.dart';

void main() {
  testWidgets('shows only API periods and reloads values after period change', (
    tester,
  ) async {
    final service = _FakeNilaiService(
      periode: const [
        NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
        NilaiPeriode(tahunAjaran: '2024/2025', semester: 'Genap'),
      ],
      nilai: {
        '2025/2026|Ganjil': const NilaiData(
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          mapel: [
            NilaiMapel(nama: 'Matematika', nilai: 85),
            NilaiMapel(nama: 'Bahasa Inggris', nilai: null),
          ],
          rataRata: 87.5,
        ),
        '2024/2025|Genap': const NilaiData(
          tahunAjaran: '2024/2025',
          semester: 'Genap',
          mapel: [NilaiMapel(nama: 'Matematika', nilai: 78)],
          rataRata: 78.0,
        ),
      },
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(find.text('2025/2026'), findsOneWidget);
    expect(find.text('Ganjil'), findsOneWidget);
    expect(find.text('Genap'), findsNothing);
    expect(find.text('87,5'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2024/2025').last);
    await tester.pumpAndSettle();

    expect(service.periodeDiminta.last.tahunAjaran, '2024/2025');
    expect(service.periodeDiminta.last.semester, 'Genap');
    expect(find.text('Genap'), findsOneWidget);
    expect(find.text('Ganjil'), findsNothing);
    expect(find.text('78'), findsOneWidget);
    expect(find.text('78,0'), findsOneWidget);
  });

  testWidgets('shows empty message when API returns no subjects', (
    tester,
  ) async {
    final service = _FakeNilaiService(
      periode: const [
        NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
      ],
      nilai: {
        '2025/2026|Ganjil': const NilaiData(
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          mapel: [],
          rataRata: null,
        ),
      },
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada nilai untuk semester ini'), findsOneWidget);
  });

  testWidgets('offers retry after period loading error', (tester) async {
    final service = _FakeNilaiService(
      periode: const [
        NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
      ],
      nilai: {
        '2025/2026|Ganjil': const NilaiData(
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          mapel: [NilaiMapel(nama: 'Matematika', nilai: 85)],
          rataRata: 85,
        ),
      },
      gagalPadaPanggilanPeriode: {1},
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Matematika'), findsOneWidget);
    expect(service.jumlahPanggilanPeriode, 2);
  });

  testWidgets('shows loading while periods are being fetched', (tester) async {
    final pendingPeriods = Completer<List<NilaiPeriode>>();
    final service = _FakeNilaiService(
      periode: const [],
      nilai: {
        '2025/2026|Ganjil': const NilaiData(
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          mapel: [NilaiMapel(nama: 'Matematika', nilai: 85)],
          rataRata: 85,
        ),
      },
      periodeTertunda: pendingPeriods,
    );

    await tester.pumpWidget(_app(service));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pendingPeriods.complete(const [
      NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Matematika'), findsOneWidget);
  });

  testWidgets('offers retry after selected semester loading error', (
    tester,
  ) async {
    final service = _FakeNilaiService(
      periode: const [
        NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
      ],
      nilai: {
        '2025/2026|Ganjil': const NilaiData(
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          mapel: [NilaiMapel(nama: 'Matematika', nilai: 85)],
          rataRata: 85,
        ),
      },
      gagalPadaPanggilanNilai: {1},
    );

    await tester.pumpWidget(_app(service));
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Matematika'), findsOneWidget);
    expect(service.jumlahPanggilanNilai, 2);
  });

  testWidgets('downloads the selected period as nilai', (tester) async {
    final service = _FakeNilaiService(
      periode: const [
        NilaiPeriode(tahunAjaran: '2025/2026', semester: 'Ganjil'),
      ],
      nilai: {
        '2025/2026|Ganjil': const NilaiData(
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          mapel: [NilaiMapel(nama: 'Matematika', nilai: 85)],
          rataRata: 85,
        ),
      },
    );
    final unduhService = _FakeUnduhService();

    await tester.pumpWidget(_app(service, unduhService: unduhService));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unduh nilai semester ini'));
    await tester.pumpAndSettle();

    expect(unduhService.jenis, JenisUnduhan.nilai);
    expect(unduhService.tahunAjaran, '2025/2026');
    expect(unduhService.semester, 'Ganjil');
  });
}

Widget _app(NilaiService service, {UnduhService? unduhService}) {
  return MaterialApp(
    home: NilaiScreen(service: service, unduhService: unduhService),
  );
}

class _FakeNilaiService implements NilaiService {
  _FakeNilaiService({
    required this.periode,
    required this.nilai,
    this.gagalPadaPanggilanPeriode = const {},
    this.gagalPadaPanggilanNilai = const {},
    this.periodeTertunda,
  });

  final List<NilaiPeriode> periode;
  final Map<String, NilaiData> nilai;
  final Set<int> gagalPadaPanggilanPeriode;
  final Set<int> gagalPadaPanggilanNilai;
  final Completer<List<NilaiPeriode>>? periodeTertunda;
  final List<NilaiPeriode> periodeDiminta = [];
  int jumlahPanggilanPeriode = 0;
  int jumlahPanggilanNilai = 0;

  @override
  Future<List<NilaiPeriode>> ambilPeriode() async {
    jumlahPanggilanPeriode++;
    final pending = periodeTertunda;
    if (pending != null) return pending.future;
    if (gagalPadaPanggilanPeriode.contains(jumlahPanggilanPeriode)) {
      throw Exception('Gagal sementara');
    }
    return periode;
  }

  @override
  Future<NilaiData> ambilNilai(NilaiPeriode pilihan) async {
    jumlahPanggilanNilai++;
    periodeDiminta.add(pilihan);
    if (gagalPadaPanggilanNilai.contains(jumlahPanggilanNilai)) {
      throw Exception('Gagal sementara');
    }
    return nilai['${pilihan.tahunAjaran}|${pilihan.semester}']!;
  }
}

class _FakeUnduhService extends UnduhService {
  JenisUnduhan? jenis;
  String? tahunAjaran;
  String? semester;

  @override
  Future<void> unduh({
    required JenisUnduhan jenis,
    required String tahunAjaran,
    required String semester,
  }) async {
    this.jenis = jenis;
    this.tahunAjaran = tahunAjaran;
    this.semester = semester;
  }
}
