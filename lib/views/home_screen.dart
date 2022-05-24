import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intern_task_level_0/controllers/item_list_controller.dart';
import 'package:intern_task_level_0/models/item_model.dart';

final currentItemProvider = Provider<Item>((_) => throw UnimplementedError());

class HomeScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _itemListControllerProvider = ref.watch(itemListControllerProvider);
    final _itemListProvider = ref.watch(itemListProvider);
    return Scaffold(
      appBar: AppBar(title: Text('TODO APP')),
      body: _itemListControllerProvider.when(
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'Tap + to add an item',
                  style: TextStyle(fontSize: 20.0),
                ),
              )
            : ListView.builder(
                itemCount: _itemListProvider.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = _itemListProvider[index];
                  return ProviderScope(
                    overrides: [currentItemProvider.overrideWithValue(item)],
                    child: ListTile(
                      key: ValueKey(item.id),
                      title: Text(item.title),
                      trailing: Checkbox(
                        value: item.isCompleted,
                        onChanged: (val) => ref
                            .read(itemListControllerProvider.notifier)
                            .updateItem(
                                updatedItem: item.copyWith(
                                    isCompleted: !item.isCompleted)),
                      ),
                      onTap: () => AddItemDialog.show(context, item),
                      onLongPress: () => ref
                          .read(itemListControllerProvider.notifier)
                          .deleteItem(itemId: item.id!),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text(error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddItemDialog.show(context, Item.empty()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// TODO作成画面
class AddItemDialog extends HookConsumerWidget {
  static void show(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(item: item),
    );
  }

  final Item item;
  const AddItemDialog({Key? key, required this.item}) : super(key: key);
  bool get isUpdating => item.id != null;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(text: item.title);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Item name'),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: isUpdating
                      ? Colors.orange
                      : Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  isUpdating
                      ? ref
                          .read(itemListControllerProvider.notifier)
                          .updateItem(
                            updatedItem: item.copyWith(
                              title: textController.text.trim(),
                              isCompleted: item.isCompleted,
                            ),
                          )
                      : ref
                          .read(itemListControllerProvider.notifier)
                          .addItem(name: textController.text.trim());
                  Navigator.of(context).pop();
                },
                child: Text(isUpdating ? 'Update' : 'Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
