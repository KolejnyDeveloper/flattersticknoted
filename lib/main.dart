import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'services/task_api_service.dart';

void main() {
  runApp(const MyApp());
}

List<IconData> prio = [
  Icons.arrow_circle_down,
  Icons.boy,
  Icons.call_made,
  Icons.medication,
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Krakflow',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final tasks = await TaskApiService.fetchTasks();

      setState(() {
        items = tasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Błąd pobierania danych z API")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = items;

    if (selectedFilter == "wykonane") {
      filteredTasks = items.where((task) => task.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = items.where((task) => !task.done).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Krakflow"),

        actions: [
          IconButton(
            icon: Icon(Icons.delete),

            color: items.isEmpty ? Colors.grey : Colors.red,

            onPressed: items.isEmpty
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Co masz usuwać jak nic nie ma?")),
                    );
                  }
                : () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Czyszczenie zadań"),

                          content: Text("Wywalamy wszystko?"),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Zaniechaj"),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  items.clear();
                                });

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Wszystko poszło...")),
                                );
                              },
                              child: Text("Tak"),
                            ),
                          ],
                        );
                      },
                    );
                  },
          ),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 12),

                Text(
                  "Masz dziś ${items.length} zadań",
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "wszystkie";
                        });
                      },

                      child: Text(
                        "Wszystkie",
                        style: TextStyle(
                          color: selectedFilter == "wszystkie"
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "do zrobienia";
                        });
                      },

                      child: Text(
                        "Do zrobienia",
                        style: TextStyle(
                          color: selectedFilter == "do zrobienia"
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "wykonane";
                        });
                      },

                      child: Text(
                        "Wykonane",
                        style: TextStyle(
                          color: selectedFilter == "wykonane"
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text("Dzisiejsze zadania", style: TextStyle(fontSize: 20)),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      return Dismissible(
                        key: Key(task.title + index.toString()),
                        direction: DismissDirection.endToStart,

                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),

                        onDismissed: (direction) {
                          setState(() {
                            items.remove(task);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Usunieto zadanie: ${task.title}'),
                            ),
                          );
                        },

                        child: TaskCard(
                          task: task,

                          onChanged: (value) {
                            setState(() {
                              task.done = value ?? false;
                            });
                          },

                          onTap: () async {
                            final editedTask = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditTaskScreen(task: task),
                              ),
                            );

                            if (editedTask != null) {
                              setState(() {
                                final originalIndex = items.indexOf(task);

                                if (originalIndex != -1) {
                                  items[originalIndex] = editedTask;
                                }
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              items.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onChanged;

  const TaskCard({super.key, required this.task, this.onTap, this.onChanged});

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;

      case 2:
        return Colors.orange;

      case 3:
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.done;

    return Card(
      child: ListTile(
        onTap: onTap,

        leading: Checkbox(value: isDone, onChanged: onChanged),

        title: Text(
          task.title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.black,
          ),
        ),

        subtitle: Text(
          task.deadline,

          style: TextStyle(color: getPriorityColor(task.priority)),
        ),

        trailing: Icon(
          prio[task.priority - 1],
          color: getPriorityColor(task.priority),
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Deadline",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: 1,
                );
                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edytuj zadanie")),

      body: Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Deadline",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final editedTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: widget.task.done,
                  priority: widget.task.priority,
                );

                Navigator.pop(context, editedTask);
              },

              child: Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}
