import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

@freezed
class Todo with _$Todo {
  factory Todo({
    required String id,
    required String description,
    @Default(false) bool completed,
  }) = _Todo;
}
