import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app_flutter/widget/shared_library/app_components/app_action.dart';
import 'package:test_app_flutter/widget/shared_library/app_components/app_label.dart';
import 'package:test_app_flutter/widget/shared_library/app_components/app_tile.dart';
import 'package:test_app_flutter/widget/shared_library/app_page/app_page.dart';
import 'package:test_app_flutter/widget/shared_library/app_page/app_page_section/card_section.dart';
import 'package:test_app_flutter/widget/shared_library/app_page/app_page_section/list_section.dart';
import 'package:test_app_flutter/widget/controller/app_controller.dart';
import 'package:test_app_flutter/widget/main/app_scaffold.dart';
import 'package:test_app_flutter/widget/todo_editor/add_todo_editor_page.dart';

class TodoEditorPage extends StatefulWidget {
  const TodoEditorPage({super.key});

  @override
  State<TodoEditorPage> createState() => _TodoEditorPageState();
}

class _TodoEditorPageState extends State<TodoEditorPage> {
  late final _appController = GetIt.instance<AppController>();

  get _appPage => AppPage(
        scaffold: AppScaffold(
          titleText: 'TODO Editor',
          floatingAction: AppItemAction(
            label: AppLabel(text: 'Add Item'),
            onPressed: (_) async {
              final newItem = await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => AddTodoItemPage()));

              if (newItem != null) {
                _addNewItem(newItem);
              }
            },
            isBlocking: false,
          ),
        ),
        loadingEmitter: _appController.todoItemsEmitter,
        sections: [
          CardSection<List<TodoItem>>(
            emitter: _appController.todoItemsEmitter,
            tileBuilder: _cardTiles,
          ),
          ListSection(
            listEmitter: _appController.todoItemsEmitter,
            itemGroups: [
              ListItemGroup<TodoItem>(
                titleText: 'In Progress',
                filter: (item) => !item.isDone,
                builder: _itemBuilder,
                showCount: false,
              ),
              ListItemGroup<TodoItem>(
                titleText: 'Completed',
                filter: (item) => item.isDone,
                builder: _itemBuilder,
                showCount: true,
              ),
            ],
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return _appPage.build();
  }

  List<Widget> _cardTiles(List<TodoItem> items) {
    return [
      AppTile(
        iconData: Icons.numbers,
        titleText: 'Count: ${items.length}',
      ).build(),
    ];
  }

  Widget _itemBuilder(TodoItem item) {
    bool isUpdating = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          leading: Checkbox(
            value: item.isDone,
            onChanged: isUpdating
                ? null
                : (value) async {
                    setState(() => isUpdating = true);
                    await _toggleTodoItem(item);
                    setState(() => isUpdating = false);
                  },
          ),
          title: Text(item.title),
          subtitle: Text(item.description ?? ''),
        );
      },
    );
  }

  Future<void> _toggleTodoItem(TodoItem item) async {
    final updatedList = _appController.todoItemsEmitter.value.map((todo) {
      if (todo == item) {
        return TodoItem(
          title: todo.title,
          description: todo.description,
          isDone: !todo.isDone, // Switch value
        );
      }
      return todo;
    }).toList();

    await Future.delayed(Duration(microseconds: 500));

    _appController.todoItemsEmitter.value = updatedList;
  }

  void _addNewItem(TodoItem item) {
    final updatedList = [..._appController.todoItemsEmitter.value, item];
    _appController.todoItemsEmitter.value = updatedList;
  }
}
