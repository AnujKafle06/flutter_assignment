// lib/task_crud_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'auth_service.dart';

class TaskCrudScreen extends StatefulWidget {
  const TaskCrudScreen({super.key});

  @override
  State<TaskCrudScreen> createState() => _TaskCrudScreenState();
}

class _TaskCrudScreenState extends State<TaskCrudScreen> {
  final _newTaskController = TextEditingController();

  Future<void> _addTask(String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    try {
      await tasksRef.add({
        'title': title,
        'completed': false,
        'createdAt': Timestamp.now(),
      });
      _newTaskController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add task: $e")));
    }
  }

  Future<void> _editTask(DocumentReference ref, String oldTitle) async {
    _newTaskController.text = oldTitle;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: TextField(controller: _newTaskController, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = _newTaskController.text.trim();
              if (value.isNotEmpty) {
                await ref.update({'title': value});
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
    _newTaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Redirect if somehow not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTaskController,
                    decoration: InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _addTask(value.trim());
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: () {
                    final value = _newTaskController.text.trim();
                    if (value.isNotEmpty) {
                      _addTask(value);
                    }
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tasks yet. Add one!'));
                }

                return ListView.separated(
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String title = data['title'] ?? '';
                    final bool completed = data['completed'] ?? false;

                    return ListTile(
                      leading: Checkbox(
                        value: completed,
                        onChanged: (value) {
                          doc.reference.update({'completed': value});
                        },
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: completed ? Colors.grey : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editTask(doc.reference, title),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => doc.reference.delete(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }
}
