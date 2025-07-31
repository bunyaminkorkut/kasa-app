

import 'dart:io';

import 'package:kasa_app/domain/core/failure_or.dart';

abstract class IPhotoRepository {
  Future<FailureOr<String>> uploadPhoto({required String jwtToken,required File photo});
}
