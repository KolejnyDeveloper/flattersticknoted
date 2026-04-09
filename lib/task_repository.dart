
class Task {
  final String title;
  final String deadline;
  final bool done;
  final int priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

List<Task> items = [
  Task(title: "z1", deadline: "tak", done: true, priority: 3),
  Task(title: "z2", deadline: "5.1.1600", done: true, priority: 1),
  Task(title: "z3", deadline: "tak", done: false, priority: 2),
  Task(title: "bajo jajo", deadline: "bajo jajo", done: false, priority: 3),
];
