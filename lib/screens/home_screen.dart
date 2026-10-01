import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box taskBox = Hive.box('taskBox');

  Future<void> _addTask() async {
    final Task? task = await showDialog<Task>(
      context: context,
      builder: (context) {
        return const TaskDialog();
      },
    );

    if (task == null) {
      return;
    }

    await taskBox.add(task.toMap());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added successfully!'),
      ),
    );
  }

  Future<void> _editTask(dynamic key, Task task) async {
    final Task? updatedTask = await showDialog<Task>(
      context: context,
      builder: (context) {
        return TaskDialog(task: task);
      },
    );

    if (updatedTask == null) {
      return;
    }

    await taskBox.put(
      key,
      updatedTask.toMap(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated successfully!'),
      ),
    );
  }

  Future<void> _deleteTask(dynamic key) async {
    await taskBox.delete(key);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted successfully!'),
      ),
    );
  }

  Task _convertToTask(dynamic value) {
    return Task.fromMap(
      Map<dynamic, dynamic>.from(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.check_circle),
            SizedBox(width: 10),
            Text(
              'My To-Do List',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),

      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return _buildEmptyState();
          }

          final List<dynamic> keys = box.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final dynamic key = keys[index];

              final dynamic value = box.get(key);

              final Task task = _convertToTask(value);

              return Dismissible(
                key: ValueKey(key),

                direction: DismissDirection.endToStart,

                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                confirmDismiss: (direction) async {
                  return await _showDeleteConfirmation();
                },

                onDismissed: (direction) async {
                  await _deleteTask(key);
                },

                child: _buildTaskCard(
                  key: key,
                  task: task,
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 90,
              color: Colors.indigo.shade300,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Tasks Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tap the Add Task button to create your first task.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required dynamic key,
    required Task task,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.task_alt,
                color: Colors.indigo.shade700,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        DateFormat(
                          'MMMM dd, yyyy',
                        ).format(task.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Edit task',
              onPressed: () {
                _editTask(key, task);
              },
              icon: const Icon(
                Icons.edit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Task',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this task?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}