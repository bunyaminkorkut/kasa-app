import 'package:dartz/dartz.dart';
import 'package:kasa_app/core/errors/failure.dart';


typedef FailureOr<T> = Either<Failure, T>;
