import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intern_task_level_0/controllers/item_list_controller.dart';
import 'package:intern_task_level_0/models/item_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final currentItemProvider = Provider<Item>((_) => throw UnimplementedError());

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // state
    final itemList = ref.watch(itemListControllerProvider);
    // provider
    final itemListNotifier = ref.watch(itemListControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('TODO APP')),
      body: itemList.when(
        data: (items) => items.isEmpty
            ? const Center(
                child: Text(
                  'タスクがありません',
                  style: TextStyle(fontSize: 20.0),
                ),
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = items[index];
                  String getTodayDate() {
                    initializeDateFormatting('ja');
                    return DateFormat('yyyy/MM/dd HH:mm', "ja")
                        .format(item.createdAt);
                  }

                  return ProviderScope(
                    overrides: [currentItemProvider.overrideWithValue(item)],
                    child: Dismissible(
                      key: ValueKey(item.id),
                      background: Container(
                        color: Colors.red,
                      ),
                      onDismissed: (_) {
                        itemListNotifier.deleteItem(
                          itemId: item.id!,
                        );
                      },
                      child: Column(
                        children: [
                          ListTile(
                            key: ValueKey(item.id),
                            title: Text(item.title),
                            subtitle: Text(getTodayDate()),
                            trailing: Checkbox(
                              value: item.isCompleted,
                              onChanged: (val) => itemListNotifier.updateItem(
                                updatedItem: item.copyWith(
                                    isCompleted: !item.isCompleted),
                              ),
                            ),
                            onTap: () => AddItemDialog.show(context, item),
                            onLongPress: () =>
                                itemListNotifier.deleteItem(itemId: item.id!),
                          ),
                          const Divider(height: 2),
                        ],
                      ),
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
    final itemListNotifier = ref.watch(itemListControllerProvider.notifier);
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
                      ? itemListNotifier.updateItem(
                          updatedItem: item.copyWith(
                            title: textController.text.trim(),
                            isCompleted: item.isCompleted,
                          ),
                        )
                      : itemListNotifier.addItem(
                          title: textController.text.trim(),
                        );
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
