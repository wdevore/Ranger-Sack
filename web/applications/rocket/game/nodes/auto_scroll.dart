part of ranger_rocket;

/**
 * A [AutoScroll] is a region where scrolling occurs when a target leaves
 * the assigned [Zone].
 * 
 * SpongyAutoScroll
 * TightAutoScroll
 * CenterLockAutoScroll
 * TweenAutoScroll
 */
abstract class AutoScroll {
  Zone zone;
  Ranger.BaseNode node;

  bool autoScrollEnabled = true;
  bool dampingEnabled = true;
  
  bool init();
  
  void updateState(Vector2 p);
  
  void release();
}