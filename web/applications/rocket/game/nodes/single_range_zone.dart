part of ranger_rocket;

/**
 * A [SingleRangeZone] is a range of space in the shape of a circle.
 * 
 */
class SingleRangeZone extends Ranger.Node with Zone {
  /**
   * The zone's radius.
   */
  double radius = 0.0;
  
  double outlineThickness = 2.0;
  List<num> _outerDashes = [2, 7, 2];
  
  SingleRangeZone();
  
  factory SingleRangeZone.initWith(Ranger.Color4<int> color, double radius) {
    SingleRangeZone o = new SingleRangeZone();
    if (o.init()) {
      o.outsideColor = color.toString();
      o.radius = o.uniformScale = radius;
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
  
  void resetAction() {
  }

  /**
   * Updates state of [SingleRangeZone].
   * Messages are sent when state changes.
   */
  void updateState(Vector2 p) {
    switch (prevState) {
      case Zone.ZONESTATE_NONE:
        bool insideInner = _inCircle(p.x, p.y);
        if (insideInner) {
          state = Zone.ZONESTATE_ENTERED;
          break;
        }
        
        if (state == Zone.ZONESTATE_NONE) {
          state = Zone.ZONESTATE_OUTSIDE;
        }
        break;
      case Zone.ZONESTATE_OUTSIDE:
        bool insideOuter = _inCircle(p.x, p.y);
        if (insideOuter) {
          state = Zone.ZONESTATE_ENTERED;
          break;
        }
        else {
          if (emitContinuousOutside)
            Ranger.Application.instance.eventBus.fire(this);
        }
        break;
      case Zone.ZONESTATE_ENTERED:
        bool insideOuter = _inCircle(p.x, p.y);
        if (!insideOuter) {
          state = Zone.ZONESTATE_EXITED;
          break;
        }
        break;
      case Zone.ZONESTATE_EXITED:
        bool insideInner = _inCircle(p.x, p.y);
        if (insideInner) {
          state = Zone.ZONESTATE_ENTERED;
        }
        else
          state = Zone.ZONESTATE_OUTSIDE;
        break;
    }

    if (prevState != state) {
      //print("$prevState => $state");
      Ranger.Application.instance.eventBus.fire(this);
    }

    prevState = state;
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
      //context2D.setLineDash(_outerDashes);
      context.drawColor = outsideColor;
      context.drawPointAt(0.0, 0.0);
      
      context.restore();
    }
  }
  
}