class Commands {
  final int id;
  final String command;
  final String title;
  final String logText;

  Commands({required this.id,
    required this.command,
    required this.title,
    required this.logText,
  });

  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "command": command,
    "title": title,
    "logText": logText
  };

  static Commands fromJson(Map<String, dynamic> json) => Commands(
    id: int.parse(json["id"]),
    command: json["command"],
    title: json["title"],
    logText: json["logText"]
  );
}