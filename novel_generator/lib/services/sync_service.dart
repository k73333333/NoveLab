abstract class SyncService {
  Future<bool> syncAll();
  Future<bool> syncCharacters();
  Future<bool> syncLocations();
  Future<bool> syncTimeline();
  Future<bool> syncOutline();
  Future<bool> syncNovel();
  Future<bool> syncProject();
}

class DummySyncService implements SyncService {
  @override
  Future<bool> syncAll() async {
    return true;
  }

  @override
  Future<bool> syncCharacters() async {
    return true;
  }

  @override
  Future<bool> syncLocations() async {
    return true;
  }

  @override
  Future<bool> syncTimeline() async {
    return true;
  }

  @override
  Future<bool> syncOutline() async {
    return true;
  }

  @override
  Future<bool> syncNovel() async {
    return true;
  }

  @override
  Future<bool> syncProject() async {
    return true;
  }
}
