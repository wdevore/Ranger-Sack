part of unittests;

/// Overlay layer.
class Hud2Layer extends Ranger.BackgroundLayer {
  Ranger.TextNode _fpsText;
  Ranger.TextNode _objectDrawnText;

  Ranger.TextNode _help;

  SingleRangeZone _centerZone;
  StreamSubscription _centerZoneSubscription;

  Hud2Layer();

  factory Hud2Layer.asTransparent([bool centered = true, int width, int height]) {
    Hud2Layer layer = new Hud2Layer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = true;
    return layer;
  }

  factory Hud2Layer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    Hud2Layer layer = new Hud2Layer();
    layer.centered = centered;
    layer.init(width, height);
    layer.color = backgroundColor;
    return layer;
  }

  @override
  void update(double dt) {
    _updateStats(dt);
  }

  void _updateStats(double dt) {
    Ranger.Application app = Ranger.Application.instance;
    if (app.updateStats) {
      // Update FPS text
      if (app.upsEnabled)
        _fpsText.text = "FPS: ${app.framesPerPeriod}, UPS: ${app.updatesPerPeriod}";
      else
        _fpsText.text = "FPS: ${app.framesPerPeriod}";

      app.framesPerPeriod = 0;
      app.updatesPerPeriod = 0;
      app.deltaAccum = 0.0;
      
      _objectDrawnText.text = "Drawn: ${app.objectsDrawn}";
    }
  }
  
  @override
  bool init([int width, int height]) {
    super.init(width, height);
    
    Ranger.Application app = Ranger.Application.instance;

    _fpsText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _fpsText.text = "--";
    _fpsText.setPosition(-position.x + 10.0, position.y - 20.0);
    _fpsText.uniformScale = 2.0;
    addChild(_fpsText, 10, 8111);
     
    _objectDrawnText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _objectDrawnText.text = "--";
    _objectDrawnText.setPosition(-position.x + 10.0, position.y - 40.0);
    _objectDrawnText.uniformScale = 2.0;
    addChild(_objectDrawnText, 10, 8112);
    
    _centerZone = new SingleRangeZone.initWith(Ranger.Color4IOrange, 300.0);
    _centerZone.uniformScale = 300.0;
    _centerZone.iconsVisible = true;
    _centerZone.zoneId = 1;
    addChild(_centerZone, 12, 930);
    
    _centerZoneSubscription = app.eventBus.on(SingleRangeZone).listen(
    (SingleRangeZone zone) {
      _singleRangeZoneAction(zone);
    });

    Ranger.Size size = contentSize;
    double hw = size.width / 2.0;
    double hh = size.height / 2.0;
    
    _help = new Ranger.TextNode.initWith(Ranger.Color4IGreen);
    _help.text = "Hold Alt and move mouse. 1 key = zoom in, 2 key = zoom out.";
    _help.setPosition(0.0, -hh + (hh * 0.15));
    _help.uniformScale = 2.0;
    addChild(_help, 10, 8111);

    return true;
  }

  void _singleRangeZoneAction(SingleRangeZone zone) {
    switch (zone.action) {
      case SingleRangeZone.ZONE_INWARD_ACTION:
        _centerZone.outsideColor = Ranger.Color4IOrange.toString();
        break;
      case SingleRangeZone.ZONE_OUTWARD_ACTION:
        // When the ship leaves the zone scroll Layer by delta.
        // The delta is how much the ship is outside of the zone.
        _centerZone.outsideColor = Ranger.Color4IGoldYellow.toString();
        break;
    }
  }

  @override
  bool onMouseMove(MouseEvent event) {
    remap();
    return true;
  }
  
  void remap() {
    GameManager gm = GameManager.instance;
    Ranger.BaseNode point = gm.sourceNode;

    // Not correct. This mapping is stating that the pointColor (aka source)
    // is a "space" and it isn't, it is a location relative to a parent
    // space. In this case the parent space is subGroupNode.
    // Note: when mapping between spaces don't start with a leaf node.
    // Leaf nodes reside "in" a space, they aren't spaces in and of themselves
    // necessarily. A point doesn't have a space, but it does reside in one.
    
    // Map point from subgroup-space to Hud-space via world-space.
    // I am supplying a "pseudo" root node as well. This is because I know
    // two things: 1) gm.groupNode is a common ancestor between subGroup
    // and HudLayer, 2) AnchorBase and Spaces2Scene transforms are perpetually
    // the Identity matrix.
    // Passing a psuedo node allows me to save a few unncessary matrix
    // multiplications on Identity matrices.
    Ranger.Vector2P pw = gm.subGroupNode.convertToWorldSpace(point.position, gm.groupNode);
    Ranger.Vector2P hudP = convertWorldToNodeSpace(pw.v, gm.groupNode);
    _centerZone.updateState(hudP.v);
     
    pw.moveToPool();
    hudP.moveToPool();
  }
  
  @override
  void onEnter() {
    enableMouse = true;

    super.onEnter();

    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    unScheduleUpdate();
  }
}
