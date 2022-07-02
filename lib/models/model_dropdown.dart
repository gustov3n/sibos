class ModelDropdown {
  String id;
  String text;

  ModelDropdown({
    this.id = "",
    this.text = "",
  });

  @override
  String toString() {
    return "id: $id, text: $text, ";
  }

  factory ModelDropdown.fromJson(Map<String, dynamic> json) {
    return ModelDropdown(
      id: json["id"] ?? "",
      text: json["text"] ?? "",
    );
  }

  void clear() {
    id = "";
    text = "";
  }
}
