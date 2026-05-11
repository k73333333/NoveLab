abstract class SyncService {
  Future<bool> upload();
  
  Future<bool> download();
  
  Future<bool> sync();
  
  String get status;
  
  void setServerUrl(String url);
  
  void setSyncInterval(int minutes);
}

class DummySyncService implements SyncService {
  String _status = 'idle';
  String _serverUrl = '';
  int _syncInterval = 60;

  @override
  Future<bool> upload() async {
    _status = 'uploading';
    await Future.delayed(const Duration(seconds: 1));
    _status = 'idle';
    return true;
  }

  @override
  Future<bool> download() async {
    _status = 'downloading';
    await Future.delayed(const Duration(seconds: 1));
    _status = 'idle';
    return true;
  }

  @override
  Future<bool> sync() async {
    _status = 'syncing';
    await download();
    await upload();
    _status = 'idle';
    return true;
  }

  @override
  String get status => _status;

  @override
  void setServerUrl(String url) {
    _serverUrl = url;
  }

  @override
  void setSyncInterval(int minutes) {
    _syncInterval = minutes;
  }
}
