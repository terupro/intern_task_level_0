import 'package:intern_task_level_0/models/item_model.dart';
import 'package:intern_task_level_0/repositories/item_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final itemListProvider =
    StateNotifierProvider<ItemListNotifier, AsyncValue<List<Item>>>((ref) {
  return ItemListNotifier(ref.read);
});

class ItemListNotifier extends StateNotifier<AsyncValue<List<Item>>> {
  final Reader _read;
  ItemListNotifier(this._read) : super(const AsyncValue.loading()) {
    retrieveItems();
  }

  // 取得
  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = const AsyncValue.loading();
    try {
      final items = await _read(itemRepositoryProvider).retrieveItems();
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // 追加
  Future<void> addItem(
      {required String title, bool isCompleted = false}) async {
    try {
      final item = Item(
        title: title,
        isCompleted: isCompleted,
        createdAt: DateTime.now(),
      );
      final itemId = await _read(itemRepositoryProvider).createItem(item: item);
      state.whenData(
        (items) => state = AsyncValue.data(
          items..add(item.copyWith(id: itemId)),
        ),
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // 更新
  Future<void> updateItem({required Item updatedItem}) async {
    try {
      await _read(itemRepositoryProvider).updateItem(item: updatedItem);
      state.whenData(
        (items) {
          state = AsyncValue.data([
            for (final item in items)
              if (item.id == updatedItem.id) updatedItem else item
          ]);
        },
      );
    } catch (e) {
      throw e.toString();
    }
  }

  // 削除
  Future<void> deleteItem({required String itemId}) async {
    try {
      await _read(itemRepositoryProvider).deleteItem(id: itemId);
      state.whenData(
        (items) => state = AsyncValue.data(
          items..removeWhere((item) => item.id == itemId),
        ),
      );
    } catch (e) {
      throw e.toString();
    }
  }
}
