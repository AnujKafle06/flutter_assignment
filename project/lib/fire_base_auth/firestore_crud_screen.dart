// lib/task_crud_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_screen.dart';
import 'auth_service.dart';

class TaskCrudScreen extends StatefulWidget {
  const TaskCrudScreen({super.key});

  @override
  State<TaskCrudScreen> createState() => _TaskCrudScreenState();
}

class _TaskCrudScreenState extends State<TaskCrudScreen>
    with TickerProviderStateMixin {
  final _newTaskController = TextEditingController();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  final String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    try {
      await tasksRef.add({
        'title': title.trim(),
        'completed': false,
        'createdAt': Timestamp.now(),
        'priority': 'medium',
        'category': 'general',
        'dueDate': null,
      });

      _newTaskController.clear();
      HapticFeedback.lightImpact();
      _showSuccessSnackBar('Task added successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to add task: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editTask(
    DocumentReference ref,
    Map<String, dynamic> taskData,
  ) async {
    final titleController = TextEditingController(
      text: taskData['title'] ?? '',
    );
    String selectedPriority = taskData['priority'] ?? 'medium';
    String selectedCategory = taskData['category'] ?? 'general';
    DateTime? selectedDueDate = taskData['dueDate']?.toDate();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Priority Selector
                const Text(
                  'Priority',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: Priority.values.map((priority) {
                    return Expanded(
                      child: RadioListTile<String>(
                        dense: true,
                        title: Text(
                          priority.displayName,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: priority.value,
                        groupValue: selectedPriority,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedPriority = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Category Selector
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: Category.values.map((category) {
                    return DropdownMenuItem(
                      value: category.value,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 16),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Due Date Selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    selectedDueDate != null
                        ? 'Due: ${_formatDate(selectedDueDate!)}'
                        : 'Set due date',
                  ),
                  trailing: selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setDialogState(() {
                              selectedDueDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDueDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  try {
                    await ref.update({
                      'title': title,
                      'priority': selectedPriority,
                      'category': selectedCategory,
                      'dueDate': selectedDueDate != null
                          ? Timestamp.fromDate(selectedDueDate!)
                          : null,
                      'updatedAt': Timestamp.now(),
                    });
                    Navigator.pop(context);
                    _showSuccessSnackBar('Task updated successfully!');
                  } catch (e) {
                    _showErrorSnackBar('Failed to update task: $e');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTask(DocumentReference ref, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await ref.delete();
        HapticFeedback.lightImpact();
        _showSuccessSnackBar('Task deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Failed to delete task: $e');
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await AuthService().signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      } catch (e) {
        _showErrorSnackBar('Failed to sign out: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return '$difference days';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Tasks'),
            Text(
              'Welcome back, ${user.displayName ?? user.email?.split('@').first ?? 'User'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: TaskSearchDelegate());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _newTaskController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        prefixIcon: const Icon(Icons.add_task),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  final value = _newTaskController.text.trim();
                                  if (value.isNotEmpty) {
                                    _addTask(value);
                                  }
                                },
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _addTask(value.trim());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: TaskFilter.values.map((filter) {
                final isSelected = _currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),

          // Task List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTasksStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docs = _filterTasks(snapshot.data!.docs);

                if (docs.isEmpty) {
                  return _buildEmptyFilterState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildTaskCard(doc, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getTasksStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<QueryDocumentSnapshot> _filterTasks(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final completed = data['completed'] ?? false;

      switch (_currentFilter) {
        case TaskFilter.active:
          return !completed;
        case TaskFilter.completed:
          return completed;
        case TaskFilter.all:
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildTaskCard(QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    final String title = data['title'] ?? '';
    final bool completed = data['completed'] ?? false;
    final String priority = data['priority'] ?? 'medium';
    final String category = data['category'] ?? 'general';
    final DateTime? dueDate = data['dueDate']?.toDate();

    final priorityData = Priority.values.firstWhere(
      (p) => p.value == priority,
      orElse: () => Priority.medium,
    );

    final categoryData = Category.values.firstWhere(
      (c) => c.value == category,
      orElse: () => Category.general,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: priorityData.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: completed,
          activeColor: Theme.of(context).primaryColor,
          onChanged: (value) async {
            HapticFeedback.lightImpact();
            try {
              await doc.reference.update({'completed': value});
            } catch (e) {
              _showErrorSnackBar('Failed to update task: $e');
            }
          },
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? Colors.grey : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityData.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priorityData.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: priorityData.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(categoryData.icon, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  categoryData.displayName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: _getDueDateColor(dueDate),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDueDateColor(dueDate),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: Colors.blue,
              onPressed: () => _editTask(doc.reference, data),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red,
              onPressed: () => _deleteTask(doc.reference, title),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return Colors.red;
    if (difference == 0) return Colors.orange;
    if (difference <= 3) return Colors.amber;
    return Colors.grey;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _focusNode.requestFocus();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No ${_currentFilter.displayName.toLowerCase()} tasks',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _currentFilter = TaskFilter.all;
              });
            },
            child: const Text('Show all tasks'),
          ),
        ],
      ),
    );
  }
}

// Enums and helper classes
enum TaskFilter {
  all('All'),
  active('Active'),
  completed('Completed');

  const TaskFilter(this.displayName);
  final String displayName;
}

enum Priority {
  low('low', 'Low', Colors.green),
  medium('medium', 'Medium', Colors.orange),
  high('high', 'High', Colors.red);

  const Priority(this.value, this.displayName, this.color);
  final String value;
  final String displayName;
  final Color color;
}

enum Category {
  general('general', 'General', Icons.task_alt),
  work('work', 'Work', Icons.work),
  personal('personal', 'Personal', Icons.person),
  shopping('shopping', 'Shopping', Icons.shopping_cart),
  health('health', 'Health', Icons.favorite);

  const Category(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final IconData icon;
}

class TaskSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text('No tasks found'));
        }

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? '';

            return ListTile(
              title: Text(title),
              onTap: () {
                close(context, title);
              },
            );
          },
        );
      },
    );
  }
}
