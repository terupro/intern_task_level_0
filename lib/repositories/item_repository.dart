import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern_task_level_0/models/item_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems();
  Future<String> createItem({required Item item});
  Future<void> updateItem({required Item item});
  Future<void> deleteItem({required String id});
}

final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref.read));

class ItemRepository implements BaseItemRepository {
  final Reader _read;
  const ItemRepository(this._read);

  // 取得
  @override
  Future<List<Item>> retrieveItems() async {
    try {
      final snap =
          await _read(firebaseFirestoreProvider).collection('lists').get();
      return snap.docs.map((doc) => Item.fromDocument(doc)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  // 追加
  @override
  Future<String> createItem({
    required Item item,
  }) async {
    try {
      final docRef = await _read(firebaseFirestoreProvider)
          .collection('lists')
          .add(item.toDocument());
      return docRef.id;
    } catch (e) {
      throw e.toString();
    }
  }

  // 更新
  @override
  Future<void> updateItem({required Item item}) async {
    try {
      await _read(firebaseFirestoreProvider)
          .collection('lists')
          .doc(item.id)
          .update(item.toDocument());
    } catch (e) {
      throw e.toString();
    }
  }

  // 削除
  @override
  Future<void> deleteItem({
    required String id,
  }) async {
    try {
      await _read(firebaseFirestoreProvider)
          .collection('lists')
          .doc(id)
          .delete();
    } catch (e) {
      throw e.toString();
    }
  }
}
