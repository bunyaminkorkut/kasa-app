import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'package:kasa_app/app_config.dart';
import 'package:kasa_app/core/errors/failure.dart';
import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/photo/i_photo_repository.dart';

class PhotoService implements IPhotoRepository {
  @override
  Future<FailureOr<String>> uploadPhoto({
    required String jwtToken,
    required File photo,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/upload-photo'));

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $jwtToken'
      ..files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return right(jsonResponse['photoUrl'] as String);
    } else {
      return left(
        ServerFailure(
          'Failed to upload photo: ${response.statusCode} - ${response.body}',
        ),
      );
    }
  }
}
