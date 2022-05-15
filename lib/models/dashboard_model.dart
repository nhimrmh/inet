class DashboardModel {
  String _name;
  Map<String, dynamic> _content;
  bool _isActivated;


  Map<String, dynamic> get content => _content;

  set content(Map<String, dynamic> value) {
    _content = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  bool get isActivated => _isActivated;

  set isActivated(bool value) {
    _isActivated = value;
  }
}