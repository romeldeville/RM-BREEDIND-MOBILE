import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/files/file_repository.dart';
import 'package:rm_breeding_mobile/features/files/share_page.dart';

class FakeFileRepository extends FileRepository {
  FakeFileRepository({List<ShareLinkInfo> links = const []})
      : links = List.of(links),
        super(Dio());

  List<ShareLinkInfo> links;
  String? lastAttachmentId;
  String? lastExportJobId;
  String? lastEntityType;
  String? lastEntityId;
  int? lastTtlHours;
  String? revokedId;

  @override
  Future<List<ShareLinkInfo>> shareLinks() async => links;

  @override
  Future<ShareLinkInfo> createShare({
    String? attachmentId,
    String? exportJobId,
    String? entityType,
    String? entityId,
    int? ttlHours,
  }) async {
    lastAttachmentId = attachmentId;
    lastExportJobId = exportJobId;
    lastEntityType = entityType;
    lastEntityId = entityId;
    lastTtlHours = ttlHours;
    final link = ShareLinkInfo(
      id: 'created-link',
      url: 'http://api/public/shares/created-token',
      filename: 'nouveau.pdf',
      accessCount: 0,
      entityType: entityType,
      entityId: entityId,
      expiresAt: DateTime.now().add(Duration(hours: ttlHours ?? 168)),
      createdAt: DateTime.now(),
    );
    links = [link, ...links];
    return link;
  }

  @override
  Future<ShareLinkInfo> revokeShare(String shareId) async {
    revokedId = shareId;
    final updated = [
      for (final link in links)
        if (link.id == shareId)
          ShareLinkInfo(
            id: link.id,
            url: link.url,
            filename: link.filename,
            accessCount: link.accessCount,
            entityType: link.entityType,
            entityId: link.entityId,
            expiresAt: link.expiresAt,
            revokedAt: DateTime.now(),
            createdAt: link.createdAt,
          )
        else
          link,
    ];
    links = updated;
    return updated.firstWhere((link) => link.id == shareId);
  }
}

ShareLinkInfo _activeLink() {
  return ShareLinkInfo(
    id: 'link-1',
    url: 'https://api.test/api/v1/public/shares/token-1',
    filename: 'photo.jpg',
    accessCount: 2,
    mimeType: 'image/jpeg',
    entityType: 'ANIMAL',
    entityId: 'animal-1',
    expiresAt: DateTime.now().add(const Duration(days: 2)),
    createdAt: DateTime.now(),
  );
}

Widget _wrap(FakeFileRepository repository, {Widget? page}) {
  return ProviderScope(
    overrides: [fileRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(home: Scaffold(body: page ?? const SharePage())),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboard;

  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        final arguments = call.arguments as Map<dynamic, dynamic>;
        clipboard = arguments['text'] as String?;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('lists share links and copies their URL', (tester) async {
    final repository = FakeFileRepository(links: [_activeLink()]);

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    expect(find.text('Liens partagés'), findsOneWidget);
    expect(find.text('photo.jpg'), findsOneWidget);
    expect(find.text('Actif • 2 accès'), findsOneWidget);

    await tester.tap(find.byTooltip('Copier le lien'));
    await tester.pumpAndSettle();

    expect(clipboard, 'https://api.test/api/v1/public/shares/token-1');
    expect(find.text('Lien copié.'), findsOneWidget);
  });

  testWidgets('requires an attachment or export identifier', (tester) async {
    final repository = FakeFileRepository();

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucun lien de partage pour le moment.'), findsOneWidget);

    await tester.tap(find.text('Créer le lien'));
    await tester.pumpAndSettle();

    expect(
      find.text('Renseignez un identifiant de pièce jointe ou d’export.'),
      findsOneWidget,
    );
    expect(repository.lastAttachmentId, isNull);
  });

  testWidgets('creates a link from an attachment and copies it', (tester) async {
    final repository = FakeFileRepository();

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Identifiant de pièce jointe (facultatif)'),
      'attachment-1',
    );
    await tester.tap(find.text('Créer le lien'));
    await tester.pumpAndSettle();

    expect(repository.lastAttachmentId, 'attachment-1');
    expect(repository.lastTtlHours, 168);
    expect(clipboard, 'http://api/public/shares/created-token');
    expect(find.text('Lien créé et copié.'), findsOneWidget);
    expect(find.text('nouveau.pdf'), findsOneWidget);
  });

  testWidgets('revokes a link after confirmation', (tester) async {
    final repository = FakeFileRepository(links: [_activeLink()]);

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Révoquer'));
    await tester.pumpAndSettle();

    expect(find.text('Révoguer le lien ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Révoquer'));
    await tester.pumpAndSettle();

    expect(repository.revokedId, 'link-1');
    expect(find.text('Révoqué • 2 accès'), findsOneWidget);
    expect(find.byTooltip('Révoquer'), findsNothing);
  });

  testWidgets('prefills the export identifier from the route', (tester) async {
    final repository = FakeFileRepository();

    await tester.pumpWidget(
      _wrap(repository, page: const SharePage(exportJobId: 'job-42')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Créer le lien'));
    await tester.pumpAndSettle();

    expect(repository.lastExportJobId, 'job-42');
    expect(repository.lastAttachmentId, isNull);
  });
}
