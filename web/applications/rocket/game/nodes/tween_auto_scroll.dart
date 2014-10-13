part of ranger_rocket;

/**
 * Note: This scroll is an experiment. It has a nasty side effect with
 * zone zooming. Use with extreme caustion.
 * [TweenAutoScroll]'s behavior is designed as an animation.
 * It also is a bit goofy. What is really needed is an AI framework
 * instead.
 */
class TweenAutoScroll extends AutoScroll {
  StreamSubscription _centerZoneSubscription;
  Vector2 scrollDirection = new Vector2.zero();

  Vector2 _targetPosition = new Vector2.zero();
  
  SingleRangeZone sZone;
  UTE.Tween _tweenScroll;
  bool _scrolling = false;
  
  TweenAutoScroll();
  
  factory TweenAutoScroll.withRadius(double radius, [int zoneId = -1]) {
    TweenAutoScroll sas = new TweenAutoScroll();
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
    Ranger.Application app = Ranger.Application.instance;
    GameManager gm = GameManager.instance;
    app.animations.stop(gm.zoomControl, Ranger.TweenAnimation.TRANSLATE_XY);

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
        break;
      case Zone.ZONESTATE_EXITED:
        zone.outsideColor = Ranger.Color4IGoldYellow.toString();
        break;
      case Zone.ZONESTATE_OUTSIDE:
        if (autoScrollEnabled && !_scrolling) {
          _scroll();
        }
        break;
    }
  }

  void _scroll() {
    Ranger.Application app = Ranger.Application.instance;

    GameManager gm = GameManager.instance;

    scrollDirection.setFrom(node.position);
    scrollDirection.sub(_targetPosition).normalize();
    
    // Calc delta to scroll
    scrollDirection.addScaled(scrollDirection, sZone.radius * 2.0);
    
    _scrolling = true;
    
    _tweenScroll = new UTE.Tween.to(gm.zoomControl, Ranger.TweenAnimation.TRANSLATE_XY, 2.0)
      ..targetRelative = [scrollDirection.x, scrollDirection.y]
      ..easing = UTE.Sine.INOUT
      ..callback = _scrollComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE;
    app.animations.add(_tweenScroll);

  }

  void _scrollComplete(int type, UTE.BaseTween source) {
    _scrolling = false;
  }
}