import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/photo/i_photo_repository.dart';
import 'package:equatable/equatable.dart';

import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:kasa_app/core/errors/failure.dart';
import 'package:kasa_app/domain/core/failure_or.dart';

class PhotoState extends Equatable {
  final Option<FailureOr<String>> photoUploadFailOrSuccess;
  final bool isUploading;

  const PhotoState({
    required this.photoUploadFailOrSuccess,
    required this.isUploading,
  });

  factory PhotoState.initial() {
    return PhotoState(
      photoUploadFailOrSuccess: none(),
      isUploading: false,
    );
  }

  PhotoState copyWith({
    Option<FailureOr<String>>? photoUploadFailOrSuccess,
    bool? isUploading,
  }) {
    return PhotoState(
      photoUploadFailOrSuccess:
          photoUploadFailOrSuccess ?? this.photoUploadFailOrSuccess,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [photoUploadFailOrSuccess, isUploading];
}


class PhotoCubit extends Cubit<PhotoState> {
  final IPhotoRepository photoRepository;

  PhotoCubit(this.photoRepository) : super(PhotoState.initial());

  Future<void> uploadPhoto({
    required String jwtToken,
    required File photo,
  }) async {
    emit(state.copyWith(isUploading: true, photoUploadFailOrSuccess: none()));

    final FailureOr<String> result = await photoRepository.uploadPhoto(
      jwtToken: jwtToken,
      photo: photo,
    );

    emit(state.copyWith(
      isUploading: false,
      photoUploadFailOrSuccess: some(result),
    ));
  }
}

