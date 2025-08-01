import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Task model included directly in the file
class Task {
  final String title;
  bool isDone;

  Task(this.title, this.isDone);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // ✅ uses super.key for modern constructor

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> taskList = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titles = prefs.getStringList('titles') ?? [];
      final status = prefs.getStringList('status') ?? [];

      setState(() {
        taskList.clear();
        for (int i = 0; i < titles.length; i++) {
          final title = titles[i];
          final isDone = (i < status.length) ? status[i] == 'true' : false;
          taskList.add(Task(title, isDone));
        }
      });
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    }
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('titles', taskList.map((t) => t.title).toList());
    prefs.setStringList('status', taskList.map((t) => t.isDone.toString()).toList());
  }

  void addTask(String title) {
    setState(() {
      taskList.add(Task(title, false));
      controller.clear();
    });
    saveTasks();
  }

  void toggleTask(int index) {
    setState(() {
      taskList[index].isDone = !taskList[index].isDone;
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
    });
    saveTasks();
  }

  void showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Task"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter task",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                addTask(text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: showAddTaskDialog,
          ),
        ],
      ),
      body: taskList.isEmpty
          ? const Center(child: Text("No tasks yet!"))
          : ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (_, index) {
          final task = taskList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                  color: task.isDone ? Colors.green : null,
                ),
                onPressed: () => toggleTask(index),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration:
                  task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteTask(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
