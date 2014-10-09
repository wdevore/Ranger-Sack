part of ranger_rocket;

/**
 * A [SingleRangeZone] is a range of space in the shape of a circle.
 * 
 */
class SingleRangeZone extends Ranger.Node with Zone {
  /// Object has entered zone
  static const int ZONESTATE_ENTERED = 10;
  /// Object has exited zone.
  static const int ZONESTATE_EXITED = 12;

  static const int ZONE_NO_ACTION = 20;
  static const int ZONE_INWARD_ACTION = 30;
  static const int ZONE_OUTWARD_ACTION = 31;

  int action = ZONE_NO_ACTION;
  
  /**
   * The zone's radius.
   */
  double radius = 0.0;
  
  bool iconsVisible = false;
  
  double outlineThickness = 2.0;
  List<num> _outerDashes = [2, 5, 2];
  
  /**
   * As long as the object is outside of the zone's range then transmit
   * an outward message.
   */
  bool emitContinuosOutside = false;
  
  SingleRangeZone();
  
  factory SingleRangeZone.initWith(Ranger.Color4<int> color, double radius) {
    SingleRangeZone o = new SingleRangeZone();
    if (o.init()) {
      o.outsideColor = color.toString();
      o.radius = radius;
      return o;
    }
    return null;
  }

  @override
  bool init() {
    if (super.init()) {
      resetAction();
      reset();
    }
    
    return true;
  }
  
  /**
   * Updates state of [SingleRangeZone].
   * Messages are sent when state changes.
   */
  void updateState(Vector2 p) {
    switch (_prevState) {
      case Zone.ZONESTATE_NONE:
        bool insideInner = _inCircle(p.x, p.y);
        if (insideInner) {
          state = ZONESTATE_ENTERED;
          _triggerInwardAction();
          //print("ZONESTATE_NONE => ZONESTATE_ENTERED_INNER");
          break;
        }
        
        if (state == Zone.ZONESTATE_NONE) {
          state = Zone.ZONESTATE_OUTSIDE;
          //print("ZONESTATE_NONE => ZONESTATE_OUTSIDE");
        }
        break;
      case Zone.ZONESTATE_OUTSIDE:
        bool insideOuter = _inCircle(p.x, p.y);
        if (insideOuter) {
          state = ZONESTATE_ENTERED;
          _triggerInwardAction();
          //print("ZONESTATE_OUTSIDE => ZONESTATE_ENTERED_OUTER");
          break;
        }
        else {
          if (emitContinuosOutside)
            _triggerOutwardAction();
        }
        break;
      case ZONESTATE_ENTERED:
        bool insideOuter = _inCircle(p.x, p.y);
        if (!insideOuter) {
          state = ZONESTATE_EXITED;
          //print("ZONESTATE_ENTERED_OUTER => ZONESTATE_EXITED_OUTER");
          _triggerOutwardAction();
          break;
        }
        break;
      case ZONESTATE_EXITED:
        bool insideInner = _inCircle(p.x, p.y);
        if (insideInner) {
          state = ZONESTATE_ENTERED;
          //print("ZONESTATE_ENTERED_INNER => ZONESTATE_EXITED_INNER");
          _triggerInwardAction();
          break;
        }
        break;
    }

    _prevState = state;
  }
  
  void _triggerInwardAction() {
    // Send message
    Ranger.Application app = Ranger.Application.instance;
    action = ZONE_INWARD_ACTION;
    app.eventBus.fire(this);
  }
  
  void _triggerOutwardAction() {
    // Send message
    Ranger.Application app = Ranger.Application.instance;
    action = ZONE_OUTWARD_ACTION;
    app.eventBus.fire(this);

    reset();
  }
  
  @override
  void reset() {
    super.reset();
  }
  
  void resetAction() {
    action = ZONE_NO_ACTION;
  }

  bool _inCircle(double x, double y) {
    double dSquared = distanceSquared(x, y);
    return dSquared <= radius * radius;  
  }

  double distanceSquared(double x, double y) {
    double dx = position.x - x;
    double dy = position.y - y;
    dx *= dx;
    dy *= dy;
    double distanceSquared = dx + dy;
    return distanceSquared;
  }
  
  double distance(double x, double y) {
    return sqrt(distanceSquared(x, y));
  }
  
  double outsideDelta(double x, double y) {
    return distance(x, y) - radius;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    if (iconsVisible) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;
  
      context.save();
  
      double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
      context.lineWidth = invScale;
  
      context.fillColor = null;
//      context2D.setLineDash(_outerDashes);
      context.drawColor = outsideColor;
      context.drawPointAt(0.0, 0.0);
      
      context.restore();
    }
  }
  
}