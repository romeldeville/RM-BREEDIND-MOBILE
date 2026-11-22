import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/files/file_repository.dart';
import 'package:rm_breeding_mobile/features/files/exports_page.dart';

class FakeFileRepository extends FileRepository {
  FakeFileRepository({List<ExportJobInfo> jobs = const []})
      : jobs = List.of(jobs),
        super(Dio());

  List<ExportJobInfo> jobs;
  String? lastType;
  Map<String, dynamic>? lastParams;

  @override
  Future<List<ExportJobInfo>> exportJobs({String? status}) async {
    return jobs;
  }

  @override
  Future<ExportJobInfo> createExportJob({
    required String type,
    Map<String, dynamic> params = const {},
  }) async {
    lastType = type;
    lastParams = params;
    final job = ExportJobInfo(
      id: 'new-job',
      type: type,
      status: 'PENDING',
      filename: 'nouvel-export.xlsx',
    );
    jobs = [job, ...jobs];
    return job;
  }

  @override
  Future<String> exportDownloadUrl(String jobId) async {
    return 'http://minio/download/$jobId';
  }
}

const _doneJob = ExportJobInfo(
  id: 'job-1',
  type: 'ANIMALS_XLSX',
  status: 'DONE',
  filename: 'animaux-2026-11-15.xlsx',
  mimeType:
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  rowCount: 12,
);

const _failedJob = ExportJobInfo(
  id: 'job-2',
  type: 'FINANCIALS_XLSX',
  status: 'FAILED',
  errorMessage: 'Erreur de génération',
);

Widget _wrap(FakeFileRepository repository) {
  return ProviderScope(
    overrides: [fileRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: Scaffold(body: ExportsPage())),
  );
}

void main() {
  testWidgets('lists export jobs with status and download link', (tester) async {
    final repository = FakeFileRepository(jobs: [_doneJob, _failedJob]);

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    expect(find.text('Mes exports'), findsOneWidget);
    expect(find.text('animaux-2026-11-15.xlsx'), findsOneWidget);
    expect(find.text('Terminé'), findsOneWidget);
    expect(find.text('12 ligne(s)'), findsOneWidget);
    expect(find.text('Échec'), findsOneWidget);
    expect(find.text('Erreur de génération'), findsOneWidget);

    await tester.tap(find.byTooltip('Télécharger'));
    await tester.pumpAndSettle();

    expect(find.text('Lien de téléchargement'), findsOneWidget);
    expect(find.text('http://minio/download/job-1'), findsOneWidget);

    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(find.text('Lien de téléchargement'), findsNothing);
  });

  testWidgets('creates an export and prepends it to the list', (tester) async {
    final repository = FakeFileRepository();

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucun export pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Générer l’export'));
    await tester.pumpAndSettle();

    expect(repository.lastType, 'ANIMALS_XLSX');
    expect(repository.lastParams, isEmpty);
    expect(find.text('nouvel-export.xlsx'), findsOneWidget);
    expect(find.text('En attente'), findsOneWidget);
    expect(find.text('Export lancé.'), findsOneWidget);
  });
}
