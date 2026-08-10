import 'package:shared_preferences/shared_preferences.dart';

class HiddenPhotoService {
  static const String _key = 'hidden_photo_ids';

  Future<Set<String>> getHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_key)?.toSet() ?? <String>{};
  }

  Future<void> hide(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = await getHiddenIds();
    ids.add(id);

    await prefs.setStringList(_key, ids.toList());
  }

  Future<void> hideMany(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();

    final hiddenIds = await getHiddenIds();
    hiddenIds.addAll(ids);

    await prefs.setStringList(
      _key,
      hiddenIds.toList(),
    );
  }

  Future<void> restore(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = await getHiddenIds();
    ids.remove(id);

    await prefs.setStringList(
      _key,
      ids.toList(),
    );
  }

  Future<void> restoreMany(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();

    final hiddenIds = await getHiddenIds();
    hiddenIds.removeAll(ids);

    await prefs.setStringList(
      _key,
      hiddenIds.toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}