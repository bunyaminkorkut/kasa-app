part of 'group_bloc.dart';

sealed class GroupEvent {
  const GroupEvent();
}

class _GroupEventGetMyGroups extends GroupEvent {
  _GroupEventGetMyGroups({required this.jwtToken});
  final String jwtToken;
  List<Object?> get props => [jwtToken];
}


class _GroupEventGetGroupRequests extends GroupEvent {
  _GroupEventGetGroupRequests({required this.jwtToken});
  final String jwtToken;
  List<Object?> get props => [jwtToken];
}

