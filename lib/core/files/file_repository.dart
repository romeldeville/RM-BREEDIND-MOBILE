import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';
import 'photo_compressor.dart';

class PresignedUpload {
  const PresignedUpload({
    required this.attachmentId,
    required this.uploadUrl,
    required this.storageKey,
    this.expiresAt,
  });

  factory PresignedUpload.fromJson(Map<String, dynamic> json) {
    return PresignedUpload(
      attachmentId: json['attachmentId'] as String? ?? '',
      uploadUrl: json['uploadUrl'] as String? ?? '',
      storageKey: json['storageKey'] as String? ?? '',
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  final String attachmentId;
  final String uploadUrl;
  final String storageKey;
  final DateTime? expiresAt;
}

class AttachmentInfo {
  const AttachmentInfo({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.filename,
    required this.confirmed,
    this.mimeType,
    this.sizeBytes,
    this.checksum,
    this.createdAt,
    this.confirmedAt,
  });

  factory AttachmentInfo.fromJson(Map<String, dynamic> json) {
    return AttachmentInfo(
      id: json['id'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      confirmed: json['confirmed'] as bool? ?? false,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      checksum: json['checksum'] as String?,
      createdAt: _parseDate(json['createdAt']),
      confirmedAt: _parseDate(json['confirmedAt']),
    );
  }

  final String id;
  final String entityType;
  final String entityId;
  final String filename;
  final bool confirmed;
  final String? mimeType;
  final int? sizeBytes;
  final String? checksum;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
}

class ExportJobInfo {
  const ExportJobInfo({
    required this.id,
    required this.type,
    required this.status,
    this.filename,
    this.mimeType,
    this.sizeBytes,
    this.rowCount,
    this.errorMessage,
    this.downloadUrl,
    this.createdAt,
    this.completedAt,
  });

  factory ExportJobInfo.fromJson(Map<String, dynamic> json) {
    return ExportJobInfo(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      filename: json['filename'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      rowCount: (json['rowCount'] as num?)?.toInt(),
      errorMessage: json['errorMessage'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      createdAt: _parseDate(json['createdAt']),
      completedAt: _parseDate(json['completedAt']),
    );
  }

  final String id;
  final String type;
  final String status;
  final String? filename;
  final String? mimeType;
  final int? sizeBytes;
  final int? rowCount;
  final String? errorMessage;
  final String? downloadUrl;
  final DateTime? createdAt;
  final DateTime? completedAt;

  bool get isDone => status == 'DONE';

  bool get isFailed => status == 'FAILED';
}

class ShareLinkInfo {
  const ShareLinkInfo({
    required this.id,
    required this.url,
    required this.filename,
    required this.accessCount,
    this.mimeType,
    this.sizeBytes,
    this.entityType,
    this.entityId,
    this.expiresAt,
    this.revokedAt,
    this.createdAt,
  });

  factory ShareLinkInfo.fromJson(Map<String, dynamic> json) {
    return ShareLinkInfo(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      accessCount: (json['accessCount'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      expiresAt: _parseDate(json['expiresAt']),
      revokedAt: _parseDate(json['revokedAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  final String id;
  final String url;
  final String filename;
  final int accessCount;
  final String? mimeType;
  final int? sizeBytes;
  final String? entityType;
  final String? entityId;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final DateTime? createdAt;

  bool get isRevoked => revokedAt != null;

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isActive => !isRevoked && !isExpired;
}

class FileRepository {
  FileRepository(this._dio, {Dio? uploadDio}) : _uploadDio = uploadDio ?? Dio();

  final Dio _dio;
  final Dio _uploadDio;
  final PhotoCompressor _compressor = const PhotoCompressor();

  Future<PresignedUpload> presignUpload({
    required String entityType,
    required String entityId,
    required String filename,
    String? mimeType,
    int? sizeBytes,
  }) async {
    final data = await _post('/attachments/presign', {
      'entityType': entityType,
      'entityId': entityId,
      'filename': filename,
      'mimeType': ?mimeType,
      'sizeBytes': ?sizeBytes,
    });
    return PresignedUpload.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<AttachmentInfo> uploadFile({
    required Uint8List bytes,
    required String entityType,
    required String entityId,
    required String filename,
    required String mimeType,
    bool compressPhoto = false,
  }) async {
    var payload = bytes;
    var contentType = mimeType;
    if (compressPhoto) {
      final compressed = await _compressor.compress(bytes);
      payload = compressed.bytes;
      contentType = 'image/jpeg';
    }
    final presigned = await presignUpload(
      entityType: entityType,
      entityId: entityId,
      filename: filename,
      mimeType: contentType,
      sizeBytes: payload.length,
    );
    try {
      await _uploadDio.put<dynamic>(
        presigned.uploadUrl,
        data: payload,
        options: Options(
          contentType: contentType,
          headers: {'Content-Length': payload.length},
        ),
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
    return confirm(presigned.attachmentId,
        checksum: sha256.convert(payload).toString());
  }

  Future<AttachmentInfo> confirm(String attachmentId, {String? checksum}) async {
    final data = await _post('/attachments/$attachmentId/confirm', {
      'checksum': ?checksum,
    });
    return AttachmentInfo.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<List<AttachmentInfo>> attachments({
    required String entityType,
    required String entityId,
  }) async {
    final data = await _get('/attachments', query: {
      'entityType': entityType,
      'entityId': entityId,
    });
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) => AttachmentInfo.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<String> attachmentDownloadUrl(String attachmentId) async {
    final data = await _get('/attachments/$attachmentId/download-url');
    return ((data as Map<String, dynamic>?) ?? const {})['url'] as String? ?? '';
  }

  Future<void> deleteAttachment(String attachmentId) async {
    try {
      await _dio.delete<dynamic>('/attachments/$attachmentId');
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<ExportJobInfo> createExportJob({
    required String type,
    Map<String, dynamic> params = const {},
  }) async {
    final data = await _post('/export-jobs', {'type': type, 'params': params});
    return ExportJobInfo.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<List<ExportJobInfo>> exportJobs({String? status}) async {
    final data = await _get('/export-jobs', query: {
      if (status != null && status.isNotEmpty) 'status': status,
    });
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) => ExportJobInfo.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<String> exportDownloadUrl(String jobId) async {
    final data = await _get('/export-jobs/$jobId/download');
    return ((data as Map<String, dynamic>?) ?? const {})['url'] as String? ?? '';
  }

  Future<ShareLinkInfo> createShare({
    String? attachmentId,
    String? exportJobId,
    String? entityType,
    String? entityId,
    int? ttlHours,
  }) async {
    final data = await _post('/shares', {
      'attachmentId': ?attachmentId,
      'exportJobId': ?exportJobId,
      'entityType': ?entityType,
      'entityId': ?entityId,
      'ttlHours': ?ttlHours,
    });
    return ShareLinkInfo.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<List<ShareLinkInfo>> shareLinks() async {
    final data = await _get('/shares');
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) => ShareLinkInfo.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<ShareLinkInfo> revokeShare(String shareId) async {
    final data = await _post('/shares/$shareId/revoke', const {});
    return ShareLinkInfo.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return response.data;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return response.data;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepository(ref.watch(dioProvider));
});
