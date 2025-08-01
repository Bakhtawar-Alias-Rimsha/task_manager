import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TaskManagerApp());

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  bool isDarkMode = false;
  List<String> tasks = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadThemePreference();
    loadTasks();
  }

  void loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    prefs.setBool('darkMode', isDarkMode);
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tasks = prefs.getStringList('tasks') ?? [];
    });
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tasks', tasks);
  }

  void addTask(String task) {
    setState(() {
      tasks.add(task);
      controller.clear();
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: isDarkMode ? Colors.black : const Color(0xFFF2F2F2),
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
      ),
      appBarTheme: AppBarTheme(
        elevation: 2,
        backgroundColor: isDarkMode ? Colors.indigo[900] : Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );

    return MaterialApp(
      title: 'Task Manager',
      theme: theme,
      home: Scaffold(
        backgroundColor: isDarkMode ? Colors.black87 : const Color(0xFFF2F2F2),
        appBar: AppBar(
          title: const Text('Task Manager'),
          actions: [
            Row(
              children: [
                Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
                Switch(
                  value: isDarkMode,
                  onChanged: toggleTheme,
                  activeColor: Colors.amber,
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter a task',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Colors.indigo),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) addTask(text);
                    },
                  ),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                  child: Text(
                    'No tasks yet!',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black54),
                  ),
                )
                    : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    return Card(
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          tasks[index],
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.amber),
                          onPressed: () => deleteTask(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
