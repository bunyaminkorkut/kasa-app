import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_app/core/errors/failure.dart';
import 'package:kasa_app/domain/core/failure_or.dart';
import 'package:kasa_app/domain/group/accept_data.dart';
import 'package:kasa_app/domain/group/create_expense_data.dart';
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
      if (event is _GroupEventSendAnswerRequest) {
        await _onSendAnswerRequest(event, emit);
      }
      if (event is _GroupEventSendAddRequest) {
        await _onSendAddRequest(event, emit);
      }
      if (event is _GroupEventCreateExpense) {
        await _onCreateExpense(event, emit);
      }
      if (event is _GroupEventCreateGroup) {
        await _onCreateGroup(event, emit);
      }
    });
  }

  void addFetchGroups({required String jwtToken}) {
    add(_GroupEventGetMyGroups(jwtToken: jwtToken));
  }

  void addCreateGroup({required String jwtToken, required String groupName}) {
    add(_GroupEventCreateGroup(jwtToken: jwtToken, groupName: groupName));
  }

  void addFetchGroupRequests({required String jwtToken}) {
    add(_GroupEventGetGroupRequests(jwtToken: jwtToken));
  }

  void addSendAnswerRequest({
    required String jwtToken,
    required int requestId,
    required bool isAccepting,
  }) {
    add(
      _GroupEventSendAnswerRequest(
        jwtToken: jwtToken,
        requestId: requestId,
        isAccepting: isAccepting,
      ),
    );
  }

  void addSendAddRequest({
    required String jwtToken,
    required int groupId,
    required String userEmail,
  }) {
    add(
      _GroupEventSendAddRequest(
        jwtToken: jwtToken,
        groupId: groupId,
        userEmail: userEmail,
      ),
    );
  }

  void addCreateExpense({
    required String jwtToken,
    required CreateExpenseData expenseData,
  }) {
    add(_GroupEventCreateExpense(jwtToken: jwtToken, expenseData: expenseData));
  }

  Future<void> _onCreateGroup(
    _GroupEventCreateGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(isCreatingGroup: true));

    final failOrGroups = await _groupRepository.createGroup(
      jwtToken: event.jwtToken,
      groupName: event.groupName,
    );

    final newState = await failOrGroups.fold(
      (failure) async {
        return state.copyWith(
          createGroupFailOrSuccess: some(false),
          isCreatingGroup: false,
        );
      },
      (groups) async {
        return state.copyWith(
          createGroupFailOrSuccess: some(true),
          getGroupsFailureOrGroups: some(right(groups)),
          isCreatingGroup: false,
        );
      },
    );

    emit(newState);
  }

  Future<void> _onGetGroups(
    _GroupEventGetMyGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(getGroupsFailureOrGroups: none(), isFetchingData: true),
    );
    final failOrGroups = await _groupRepository.getGroups(
      jwtToken: event.jwtToken,
    );

    final newState = await failOrGroups.fold(
      (failure) async {
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
    emit(state.copyWith(requestsOption: none(), isFetchingRequests: true));

    final failOrRequests = await _groupRepository.getRequests(
      jwtToken: event.jwtToken,
    );

    final newState = failOrRequests.fold(
      (failure) {
        return state.copyWith(
          getGroupRequestsFailureOrRequests: some(left(failure)),
          requestsOption: none(),
          isFetchingRequests: false,
        );
      },
      (requests) {
        return state.copyWith(
          getGroupRequestsFailureOrRequests: some(right(requests)),
          requestsOption: some(requests),
          isFetchingRequests: false,
        );
      },
    );

    emit(newState);
  }

  Future<void> _onSendAnswerRequest(
    _GroupEventSendAnswerRequest event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(isSendingReqAnswer: event.requestId));

    final failOrResponse = event.isAccepting
        ? await _groupRepository.acceptRequest(
            jwtToken: event.jwtToken,
            requestId: event.requestId,
          )
        : await _groupRepository.rejectRequest(
            jwtToken: event.jwtToken,
            requestId: event.requestId,
          );

    failOrResponse.fold(
      (failure) {
        emit(state.copyWith(isSendingReqAnswer: -1, isFetchingRequests: false));
      },
      (response) {
        if (event.isAccepting) {
          final answerResponse = response as AcceptResponse;
          emit(
            state.copyWith(
              isSendingReqAnswer: -1,
              getGroupRequestsFailureOrRequests: some(
                right(answerResponse.requests),
              ),
              getGroupsFailureOrGroups: some(right(answerResponse.groups)),
              requestsOption: some(answerResponse.requests),
              isFetchingRequests: false,
            ),
          );
        } else {
          final answerResponse = response as KtList<GroupRequestData>;
          emit(
            state.copyWith(
              isSendingReqAnswer: -1,
              getGroupRequestsFailureOrRequests: some(right(answerResponse)),
              requestsOption: some(answerResponse),
              isFetchingRequests: false,
            ),
          );
        }
      },
    );
  }

  Future<void> _onSendAddRequest(
    _GroupEventSendAddRequest event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(
        sendingAddGroupReq: true,
        sendAddGroupReqFailureOrRequests: none(),
      ),
    );

    final failOrResponse = await _groupRepository.sendAddGroupRequest(
      jwtToken: event.jwtToken,
      groupId: event.groupId,
      memberEmail: event.userEmail,
    );

    failOrResponse.fold(
      (failure) {
        final errorMessage = failure is ServerFailure
            ? failure.message
            : "Bir hata oluştu";

        emit(
          state.copyWith(
            sendingAddGroupReq: false,
            sendAddGroupReqFailureOrRequests: some(false),
            sendAddGroupReqErrorMessage: errorMessage,
          ),
        );
      },
      (updatedGroup) {
        final updatedGroups = state.getGroupsFailureOrGroups.map(
          (either) => either.map((groupList) {
            final list = groupList.asList().toList();
            final index = list.indexWhere((g) => g.id == updatedGroup.id);
            if (index != -1) {
              list[index] = updatedGroup;
            } else {
              list.add(updatedGroup);
            }
            return KtList.from(list);
          }),
        );

        emit(
          state.copyWith(
            sendingAddGroupReq: false,
            sendAddGroupReqFailureOrRequests: some(true),
            getGroupsFailureOrGroups: updatedGroups,
          ),
        );
      },
    );
  }

  Future<void> _onCreateExpense(
    _GroupEventCreateExpense event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(creatingExpense: true, createExpenseFailOrSuccess: none()),
    );

    final failOrResponse = await _groupRepository.createExpense(
      jwtToken: event.jwtToken,
      expenseData: event.expenseData,
    );

    failOrResponse.fold(
      (failure) {
        emit(
          state.copyWith(
            creatingExpense: false,
            createExpenseFailOrSuccess: some(false),
          ),
        );
      },
      (newExpense) {
        final updatedGroups = state.getGroupsFailureOrGroups.map(
          (either) => either.map((groupList) {
            final updatedList = groupList.asList().map((group) {
              if (group.id == newExpense.expense.groupId) {
                final updatedExpenses = group.expenses.toList();
                updatedExpenses.insert(0, newExpense.expense); // En üste ekle
                return group.copyWith(
                  expenses: updatedExpenses.toList(),
                  debts: newExpense.debts,
                  credits: newExpense.credits,
                );
              }
              return group;
            }).toList();

            return KtList.from(updatedList);
          }),
        );

        emit(
          state.copyWith(
            creatingExpense: false,
            createExpenseFailOrSuccess: some(true),
            getGroupsFailureOrGroups: updatedGroups,
          ),
        );
      },
    );
  }

  final IGroupRepository _groupRepository;
}
