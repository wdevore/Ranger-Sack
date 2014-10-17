part of twenty48;

class GridMessage {
  static const int ACTION_NONE = 100;
  static const int ACTION_LOST = 101;
  static const int ACTION_WON = 102;
  static const int ACTION_SCORE_CHANGED = 103;
  
  int action = ACTION_NONE;
  
  int mergedValue;
}