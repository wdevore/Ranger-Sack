part of ranger_rocket;

/**
 * [TightAutoScroll]'s behavior is designed to be a tight response.
 */
class TightAutoScroll extends AutoScroll {
  StreamSubscription _centerZoneSubscription;
  Vector2 scrollDirection = new Vector2.zero();
  Vector2 zoneEdgePosition = new Vector2.zero();

  static const double DampingMax = 0.2;
  static const double DampingMin = 0.1;
  double damping = DampingMax;
  double dampingFalloff = 0.005;

  Vector2 _targetPosition = new Vector2.zero();
  
  SingleRangeZone sZone;
  
  TightAutoScroll();
  
  factory TightAutoScroll.withRadius(double radius, [int zoneId = -1]) {
    TightAutoScroll sas = new TightAutoScroll();
    if (sas.init()) {
      sas.initWithRadius(radius, zoneId);
      return sas;
    }
    
    return null;
  }
  
  bool init() {
    _centerZoneSubscription = Ranger.Application.instance.eventBus.on(SingleRangeZone).listen(
    (SingleRangeZone zone) {
      _singleRangeZoneAction(zone);
    });
    
    return true;
  }
  
  bool initWithRadius(double radius, int zoneId) {

    node = new SingleRangeZone.initWith(Ranger.Color4IOrange, radius);
    zone = node as Zone;
    sZone = node as SingleRangeZone;
    
    zone.iconsVisible = false;
    zone.emitContinuousOutside = true;
    zone.zoneId = zoneId;

    return true;
  }
  
  void release() {
    _centerZoneSubscription.cancel();
  }

  /**
   * [p] is typically a Hud-space position of the ship.
   */
  void updateState(Vector2 p) {
    _targetPosition.setFrom(p);
    zone.updateState(p);
  }

  // This is called whenever the state of the Zone changes.
  // The state is updated during the update(dt) call.
  void _singleRangeZoneAction(SingleRangeZone zone) {
    switch (zone.state) {
      case Zone.ZONESTATE_ENTERED:
        zone.outsideColor = Ranger.Color4IOrange.toString();
        break;
      case Zone.ZONESTATE_EXITED:
        zone.outsideColor = Ranger.Color4IGoldYellow.toString();
        break;
      case Zone.ZONESTATE_OUTSIDE:
        if (autoScrollEnabled) {
          _scroll();
        }
        break;
    }
  }

  void _scroll() {
    GameManager gm = GameManager.instance;

    scrollDirection.setFrom(node.position);
    scrollDirection.sub(_targetPosition).normalize();
    
    double distance = zone.distance(_targetPosition.x, _targetPosition.y);
    double delta = distance - sZone.radius;

    if (dampingEnabled)
      scrollDirection.scale(delta * damping);
    else
      scrollDirection.scale(delta);
    
    gm.zoomControl.translateBy(scrollDirection);
    
    damping -= dampingFalloff;
    if (damping < DampingMin)
      damping = DampingMin;
  }

}