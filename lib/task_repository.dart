class Task {
  final int id;
  final String title;
  final String deadline;

  bool done;

  final int priority;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "priority": priority,
      "done": done,
    };
  }

  factory Task.fromMap(Map map) {
    return Task(
      id: map["id"],
      title: map["title"],
      deadline: map["deadline"],
      priority: map["priority"],
      done: map["done"],
    );
  }
}

List<Task> items = [
  Task(id: 1593, title: "z1", deadline: "tak", done: true, priority: 3),
  Task(id: 2393, title: "z2", deadline: "5.1.1600", done: true, priority: 1),
  Task(id: 4393,title: "z3", deadline: "tak", done: false, priority: 2),
  Task(id: 9993,title: "bajo jajo", deadline: "bajo jajo", done: false, priority: 3),
];
