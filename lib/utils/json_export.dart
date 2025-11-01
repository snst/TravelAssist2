abstract class JsonExport {
  Future<String> toJson();
  void fromJson(String? jsonString, bool append);
  Future<void> clear();
}