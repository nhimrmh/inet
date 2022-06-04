import '../config/config.dart';
import '../models/channel_measure.dart';

String getChannelName(String input) {
  ChannelMeasure currentMeasure = ChannelMeasure();
  try {
    currentMeasure = listChannelMeasure.where((measure) => measure.channelID == input).first;
  }
  catch(e) {
    currentMeasure = null;
  }
  return currentMeasure != null ? currentMeasure.channelName : input;
}