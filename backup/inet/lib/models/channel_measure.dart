class ChannelMeasure {
  String _channelID;
  String _channelName;
  String _unit;

  String get channelID => _channelID;

  set channelID(String value) {
    _channelID = value;
  }

  String get channelName => _channelName;

  String get unit => _unit;

  set unit(String value) {
    _unit = value;
  }

  set channelName(String value) {
    _channelName = value;
  }
}