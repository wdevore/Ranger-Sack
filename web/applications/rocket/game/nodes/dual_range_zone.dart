part of ranger_rocket;

/**
 * A [DualRangeZone] is a range of space in the shape of a ring band.
 * 
 * The inner region is considered entering. The outer region is considered
 * exiting.
 * First an object must "enter" the inner region first before an exit can
 * be considered to occur. Until an object enters the inner region exiting
 * the outer region does nothing.
 */
class DualRangeZone extends Ranger.Node with Zone {
  /// Object is outside the Zone's outer region
  static const int ZONESTATE_ENTERED_OUTER = 10;
  static const int ZONESTATE_ENTERED_INNER = 11;
  static const int ZONESTATE_EXITED_INNER = 12;
  static const int ZONESTATE_EXITED_OUTER = 13;

  static const int ZONE_NO_ACTION = 20;
  static const int ZONE_INWARD_ACTION = 30;
  static const int ZONE_OUTWARD_ACTION = 31;

  int action = ZONE_NO_ACTION;
  
  double innerRegionRadius = 0.0;
  double outerRegionRadius = 0.0;
  
  bool _enteredInner = false;
  
  bool iconsVisible = false;
  
  double outlineThickness = 2.0;
  List<num> _outerDashes = [1, 5, 1];
  List<num> _innerDashes = [1, 3, 1];
  
  DualRangeZone();
  
  factory DualRangeZone.initWith(Ranger.Color4<int> innerColor, Ranger.Color4<int> outerColor, double innerRadius, double outerRadius) {
    DualRangeZone o = new DualRangeZone();
    if (o.init()) {
      o.insideColor = innerColor.toString();
      o.outsideColor = outerColor.toString();
      o.innerRegionRadius = innerRadius;
      o.outerRegionRadius = outerRadius;
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
   * Updates state of [DualRangeZone].
   * Messages are sent when state changes.
   */
  void updateState(Vector2 p) {
    switch (prevState) {
      case Zone.ZONESTATE_NONE:
        bool insideInner = _inCircle(p.x, p.y, innerRegionRadius);
        if (insideInner) {
          state = ZONESTATE_ENTERED_INNER;
          _triggerInwardAction();
          //print("ZONESTATE_NONE => ZONESTATE_ENTERED_INNER");
          break;
        }
        
        bool insideOuter = _inCircle(p.x, p.y, outerRegionRadius);
        if (insideOuter) {
          state = ZONESTATE_ENTERED_OUTER;
          //print("ZONESTATE_NONE => ZONESTATE_ENTERED_OUTER");
          break;
        }
        
        if (state == Zone.ZONESTATE_NONE) {
          state = Zone.ZONESTATE_OUTSIDE;
          //print("ZONESTATE_NONE => ZONESTATE_OUTSIDE");
        }
        break;
      case Zone.ZONESTATE_OUTSIDE:
        bool insideOuter = _inCircle(p.x, p.y, outerRegionRadius);
        if (insideOuter) {
          state = ZONESTATE_ENTERED_OUTER;
          //print("ZONESTATE_OUTSIDE => ZONESTATE_ENTERED_OUTER");
          break;
        }
        break;
      case ZONESTATE_ENTERED_OUTER:
        bool insideOuter = _inCircle(p.x, p.y, outerRegionRadius);
        if (!insideOuter) {
          state = ZONESTATE_EXITED_OUTER;
          //print("ZONESTATE_ENTERED_OUTER => ZONESTATE_EXITED_OUTER");
          break;
        }

        bool insideInner = _inCircle(p.x, p.y, innerRegionRadius);
        if (insideInner) {
          state = ZONESTATE_ENTERED_INNER;
          _triggerInwardAction();
          //print("ZONESTATE_ENTERED_OUTER => ZONESTATE_ENTERED_INNER");
          break;
        }
        break;
      case ZONESTATE_ENTERED_INNER:
        bool insideInner = _inCircle(p.x, p.y, innerRegionRadius);
        if (!insideInner) {
          state = ZONESTATE_EXITED_INNER;
          //print("ZONESTATE_ENTERED_INNER => ZONESTATE_EXITED_INNER");
          break;
        }
        break;
      case ZONESTATE_EXITED_INNER:
        bool insideInner = _inCircle(p.x, p.y, innerRegionRadius);
        if (insideInner) {
          state = ZONESTATE_ENTERED_INNER;
          _triggerInwardAction();
          //print("ZONESTATE_EXITED_INNER => ZONESTATE_ENTERED_INNER");
          break;
        }

        bool insideOuter = _inCircle(p.x, p.y, outerRegionRadius);
        if (!insideOuter) {
          state = ZONESTATE_EXITED_OUTER;
          //print("ZONESTATE_EXITED_INNER => ZONESTATE_EXITED_OUTER");
          if (_enteredInner) {
            _triggerOutwardAction();
          }
          break;
        }
        break;
      case ZONESTATE_EXITED_OUTER:
        if (_enteredInner) {
          //print("ZONESTATE_EXITED_OUTER => TRIGGER outgoing");
          _triggerOutwardAction();
        }
        state = Zone.ZONESTATE_OUTSIDE;
        break;
    }

    prevState = state;
  }
  
  void _triggerInwardAction() {
    if (!_enteredInner) {
      // Send message
      Ranger.Application app = Ranger.Application.instance;
      action = ZONE_INWARD_ACTION;
      app.eventBus.fire(this);
    }
    _enteredInner = true;
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
    _enteredInner = false;
  }
  
  void resetAction() {
    action = ZONE_NO_ACTION;
  }

  bool _inCircle(double x, double y, double radius) { 
    double dx = position.x - x;
    double dy = position.y - y;
    dx *= dx;
    dy *= dy;
    double distanceSquared = dx + dy;
    double radiusSquared = radius * radius;
    return distanceSquared <= radiusSquared;  
  }

  double distance(double x, double y) {
    return 0.0;
  }
  
  @override
  void draw(Ranger.DrawContext context) {
    if (iconsVisible) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;
  
      context.save();
  
      double invScale = 1.0 / calcUniformScaleComponent() * outlineThickness;
      context.lineWidth = invScale;
  
      context.fillColor = null;
      context2D.setLineDash(_innerDashes);
      context.drawColor = insideColor;
      context.drawPointAt(0.0, 0.0, innerRegionRadius);
  
      context2D.setLineDash(_outerDashes);
      context.drawColor = outsideColor;
      context.drawPointAt(0.0, 0.0, outerRegionRadius);
      
      context.restore();
    }
  }
  
}