import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/domain/group/i_group_repository.dart';
import 'package:kasa_app/domain/group/request_data.dart';
import 'package:kt_dart/collection.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc(this._groupRepository) : super(GroupState.initial()) {
    on<GroupEvent>((event, emit) async {
      if (event is _GroupEventGetMyGroups) {
        await _onGetGroups(event, emit);
      }
      if (event is _GroupEventGetGroupRequests) {
        await _onGetGroupRequests(event, emit);
      }
    });
  }

  void addFetchGroups({required String jwtToken}) {
    add(_GroupEventGetMyGroups(jwtToken: jwtToken));
  }

  void addFetchGroupRequests({required String jwtToken}) {
    add(_GroupEventGetGroupRequests(jwtToken: jwtToken));
  }

  Future<void> _onGetGroups(
    _GroupEventGetMyGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(getGroupsFailureOrGroups: none(), isFetchingData: true),
    );
    print('Fetching groups with JWT: ${event.jwtToken}');
    final failOrGroups = await _groupRepository.getGroups(
      jwtToken: event.jwtToken,
    );

    final newState = await failOrGroups.fold(
      (failure) async {
        print(failure);
        return state.copyWith(
          getGroupsFailureOrGroups: some(left(failure)),
          isFetchingData: false,
        );
      },
      (groups) async {
        return state.copyWith(
          getGroupsFailureOrGroups: some(right(groups)),
          isFetchingData: false,
        );
      },
    );

    emit(newState);
  }

  Future<void> _onGetGroupRequests(
    _GroupEventGetGroupRequests event,
    Emitter<GroupState> emit,
  ) async {
    print('Fetching group requests with JWT: ${event.jwtToken}');
    emit(
      state.copyWith(
        getGroupRequestsFailureOrRequests: none(),
        requestsOption: none(),
        isFetchingData: true,
      ),
    );
    final failOrRequests = await _groupRepository.getRequests(
      jwtToken: event.jwtToken,
    );

    final newState = await failOrRequests.fold(
      (failure) async {
        print(failure);
        return state.copyWith(
          getGroupRequestsFailureOrRequests: some(left(failure)),
          isFetchingData: false,
        );
      },
      (requests) async {
        return state.copyWith(
          getGroupRequestsFailureOrRequests: some(right(requests)),
          requestsOption: some(requests),
          isFetchingData: false,
        );
      },
    );

    emit(newState);
  }

  final IGroupRepository _groupRepository;
}
