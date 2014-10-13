part of ranger_rocket;

/**
 * A [Zone] is a region of space.
 * 
 * The inner region is considered entering. The outer region is considered
 * exiting.
 * First an object must "enter" the inner region first before an exit can
 * be considered to occur. Until an object enters the inner region exiting
 * the outer region does nothing.
 * 
 * [Zone]s use the messaging system (aka [EventBus]) to transmit an
 * instance of itself to listeners.
 */
abstract class Zone {
  /// Object has remained in side since the last check.
  static const int ZONESTATE_NONE = 0;
  /// Object has officially entered zone.
  static const int ZONESTATE_ENTERED = 1;
  /// Object has officially exited zone.
  static const int ZONESTATE_EXITED = 2;
  /// Object is inside the Zone's outer region
  static const int ZONESTATE_INSIDE = 3;
  /// Object is outside the Zone's outer region
  static const int ZONESTATE_OUTSIDE = 4;
  
  int zoneId = -1;
  
  String insideColor;
  String outsideColor;

  /**
   * As long as the object is outside of the zone's range then transmit
   * an outward message.
   */
  bool emitContinuousOutside = false;

  bool iconsVisible = false;
  
  String name;
  
  // Between frames we need to check if the object has entered or exited.
  int prevState;

  int state;
  
  /**
   * Updates state of [Zone]
   */
  void updateState(Vector2 p);
  
  void reset() {
    state = prevState = ZONESTATE_NONE;
  }
  
  double distance(double x, double y);
  
//  void resetAction();
}