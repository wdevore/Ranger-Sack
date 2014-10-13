part of ranger_rocket;

/**
 * [SpongyAutoScroll]'s behavior is designed to be some what spongy or springy.
 */
class SpongyAutoScroll extends AutoScroll {
  StreamSubscription _centerZoneSubscription;
  Vector2 scrollDirection = new Vector2.zero();

  double _reduction = 0.0;
  double damping = 0.001;

  Vector2 _targetPosition = new Vector2.zero();
  
  SingleRangeZone sZone;
  
  SpongyAutoScroll();
  
  factory SpongyAutoScroll.withRadius(double radius, [int zoneId = -1]) {
    SpongyAutoScroll sas = new SpongyAutoScroll();
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
   * [p] is typically a Hud-space position.
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
        _reduction = 0.0;
        break;
      case Zone.ZONESTATE_EXITED:
        zone.outsideColor = Ranger.Color4IGoldYellow.toString();
        _reduction = 0.0;
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

    if (_reduction > 1.0)
      _reduction = 1.0;
    else {
      if (dampingEnabled)
        _reduction += damping;
      else
        _reduction = 1.0;
    }
    
    delta *= _reduction;
    scrollDirection.scale(delta);
    
    gm.zoomControl.translateBy(scrollDirection);
  }

}