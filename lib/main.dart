import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final int priority;

  Task({required this.title, required this.deadline, required this.done, required this.priority});
}

List<Task> items = [
  Task(title: "z1", deadline: "tak", done: true, priority: 4),
  Task(title: "z2", deadline: "5.1.1600", done: true, priority: 1),
  Task(title: "z3", deadline: "tak", done: false, priority: 2),
  Task(title: "bajo jajo", deadline: "bajo jajo", done: false, priority: 3),
];

List<IconData> prio = [Icons.arrow_circle_down, Icons.boy, Icons.call_made, Icons.medication];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.white)),
      home: Column(
        children: [
          Text("Masz dziś ${items.length} zadania"),
          SizedBox(height: 16),
          Text("Dzisiejsze zadania"),
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    title: items[index].title,
                    subtitle: items[index].deadline,
                    icon: items[index].done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    picon: prio[items[index].priority],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData picon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.picon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(picon),
      ),
    );
  }
}
