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
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";

  @override
  Widget build(BuildContext context) {

    List<Task> filteredTasks = items;

    if (selectedFilter == "wykonane") {
      filteredTasks = items
          .where((task) => task.done)
          .toList();

    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = items
          .where((task) => !task.done)
          .toList();
    }
    return MaterialApp(
      title: 'Krakflow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),

      home: Scaffold(
        appBar: AppBar(
          title: Text("Krakflow"),

          actions: [
            IconButton(
              icon: Icon(Icons.delete),

              color: items.isEmpty ? Colors.grey : Colors.red,

              onPressed: items.isEmpty ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "co masz usuwac jak nic ni ma?",
                    ),
                  ),
                );
              }

                  : () {
                showDialog(
                  context: context,

                  builder: (context) {
                    return AlertDialog(
                      title: Text("Czyszczenie zadan"),

                      content: Text(
                        "Wywalamy wszystko?",
                      ),

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
                              SnackBar(
                                content: Text(
                                  "Wszysko poszlo...",
                                ),
                              ),
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
        body: Column(
          children: [
            Text("Masz dziś ${items.length} zadania"),
            SizedBox(height: 8),

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
            Text("Dzisiejsze zadania"),
            Expanded(
              //child: TaskListScreen(),
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
                        items.removeAt(index);
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
                            items[index] = editedTask;
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );

              final Task? newTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(),
                ),
              );
              if (newTask != null) {
                setState(() {
                  items.add(newTask);
                });
              }

            },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onChanged,
  });

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

        leading: Checkbox(
          value: isDone,
          onChanged: onChanged,
        ),

        title: Text(
          task.title,
          style: TextStyle(
            decoration:
            isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.black,
          ),
        ),

        subtitle: Text(
          task.deadline,
          style: TextStyle(
            color: getPriorityColor(task.priority),
          ),
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
      appBar: AppBar(
        title: Text("Nowe zadanie"),
      ),
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
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  done: false,
                  priority: 1
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

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.task.title);

    deadlineController =
        TextEditingController(text: widget.task.deadline);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj zadanie"),
      ),

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

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}
class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> tasksFuture;
  @override
  void initState() {
    super.initState();
    tasksFuture = TaskApiService.fetchTasks();
  }
  String selectedFilter = "wszystkie";
  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = items;

    if (selectedFilter == "wykonane") {
      filteredTasks = items
          .where((task) => task.done)
          .toList();

    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = items
          .where((task) => !task.done)
          .toList();
    }

    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        List<Task> filteredTasks = snapshot.data ?? [];
        return ListView.builder(
          itemCount: tasks.length,
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
                  items.removeAt(index);
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
                      items[index] = editedTask;
                    });
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
