import 'package:equatable/equatable.dart';

class GroupData extends Equatable {
  const GroupData({
    required this.name,
    required this.id,
    required this.createdDate,
  });

  final String name;
  final int id;
  final DateTime createdDate;

  GroupData copyWith({String? name, int? id, DateTime? createdDate}) {
    return GroupData(
      name: name ?? this.name,
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id};
  }

  factory GroupData.fromMap(Map<String, dynamic> map) {
    return GroupData(
      name: map['name'] as String,
      id: map['id'] as int,
      createdDate: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int)*1000, 
      ),
    );
  }

  @override
  List<Object?> get props => [name, id];
}
