part of ranger_rocket;

/// Overlay layer.
class HudLayer extends Ranger.BackgroundLayer {
  static int _nextTag = 100000;
  
  Ranger.TextNode _fpsText;
  Ranger.TextNode _objectDrawnText;
  Ranger.TextNode _messageText;
  
  Ranger.GroupNode _help;
  int _listTag;
  Ranger.SpriteImage _listSprite;

  bool _loaded = false;
  int _loadingCount = 0;

  Ranger.OverlayLayer _loadingOverlay;
  Ranger.SpriteImage _overlaySpinner;

  // Center Zone = auto scroll ring
  double centerZoneRadius = 0.0;  // computed below

  StreamSubscription _centerZoneSubscription;
//  bool autoScrollEnabled = true;
  
  Vector2 shipHudPosition = new Vector2.zero();
  Vector2 zoneEdgePosition = new Vector2.zero();
  Vector2 scrollDirection = new Vector2.zero();
  Vector2 hudOrigin = new Vector2.zero();

  AutoScroll autoScroll;
  
  HudLayer();

  factory HudLayer.asTransparent([bool centered = true, int width, int height]) {
    HudLayer layer = new HudLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = true;
    return layer;
  }

  factory HudLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    HudLayer layer = new HudLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.color = backgroundColor;
    return layer;
  }

  @override
  void update(double dt) {
    _updateStats(dt);
    // Note: It isn't very efficient to remap inside an update().
    // We should only remap when things change, like an Actor moving.
    remap();
    autoScroll.updateState(shipHudPosition);
  }

  void remap() {
    GameManager gm = GameManager.instance;
    TriangleShip triShip = gm.triShip;
    
    // Map ship's position from ship-space to Hud-space via world-space.
    Ranger.Vector2P pw = gm.zoomControl.convertToWorldSpace(triShip.position);
    Ranger.Vector2P hudP = convertWorldToNodeSpace(pw.v);
    shipHudPosition.setFrom(hudP.v);
    
    pw.moveToPool();
    hudP.moveToPool();
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
  bool onMouseDown(MouseEvent event) {
    if (!_loaded)
      return false;
    
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_listSprite, event.offset.x, event.offset.y);
    //        v-----------------------------------^
    // The mapping methods always return pooled objects, so be sure to
    // return them to the pool otherwise your app will progressively
    // leak.
    nodeP.moveToPool();

    if (_listSprite.pointInside(nodeP.v)) {
      _listSprite.rotationByDegrees = 0.0;
      app.animations.stop(_listSprite, Ranger.TweenAnimation.ROTATE);

      _wiggleListSprite();
      
      // Transmit icon clicked message. This message will be picked
      // up by GameScene which is listening on the bus.
      MessageData md = new MessageData();
      md.actionData = MessageData.SHOW_PANEL;
      app.eventBus.fire(md);

      return true;
    }

    return false;
  }

  void _wiggleListSprite() {
    Ranger.Application app = Ranger.Application.instance;
    
    // Create an animation that when completed will trigger a transition.
    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween tw1 = app.animations.rotateTo(
        _listSprite,
        0.15,
        -5.0, // CW
        UTE.Cubic.OUT,
        null, false);

    seq.push(tw1);

    UTE.Tween tw2 = app.animations.rotateTo(
        _listSprite,
        0.15,
        10.0,
        UTE.Cubic.OUT,
        null, false);

    seq.push(tw2);

    UTE.Tween tw3 = app.animations.rotateTo(
        _listSprite,
        0.15,
        0.0,
        UTE.Cubic.OUT,
        null, false);

    seq.push(tw3);
    
    seq.start();
  }

  @override
  void onEnter() {
    enableKeyboard = false;
    enableTouch = true;
    
    super.onEnter();

    Ranger.Size<double> size = contentSize;
    double hWdith = size.width / 2.0;
    double hHeight = size.height / 2.0;

    GameManager gm = GameManager.instance;

    addChild(gm.spikeShip, 10);
    gm.spikeShip.configure(this);
    gm.spikeShip.uniformScale = gm.spikeShip.baseScale = 25.0;
    gm.spikeShip.visible = false;

    Ranger.Application.instance.eventBus.on(ZoomGroup).listen(
    (ZoomGroup zg) {
      gm.spikeShip.uniformScale = gm.spikeShip.baseScale * zg.currentScale;
    });

    //---------------------------------------------------------------
    // Create nodes.
    //---------------------------------------------------------------
    _fpsText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _fpsText.text = "--";
    _fpsText.setPosition(-position.x + 10.0, position.y - 30.0);
    _fpsText.uniformScale = 3.0;
    addChild(_fpsText, 10, 111);
     
    _objectDrawnText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _objectDrawnText.text = "--";
    _objectDrawnText.setPosition(-position.x + 10.0, position.y - 60.0);
    _objectDrawnText.uniformScale = 3.0;
    addChild(_objectDrawnText, 10, 111);
    
    _messageText = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _messageText.text = "";
    _messageText.setPosition(0.0, hHeight - 100.0);
    _messageText.uniformScale = 5.0;
    addChild(_messageText, 10, 111);
    
    _configureHelp();

    _setViewportAABBox();

    _listTag = _loadImage("resources/list.svg", 32, 32,
        hWdith - (hWdith * .7), hHeight - (hHeight * .1), false);

    _configOverlay();

    _configureAutoScroll();
    
    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    Ranger.Application app = Ranger.Application.instance;
    app.animations.stop(_listSprite, Ranger.TweenAnimation.ROTATE);
    app.animations.stop(_messageText, Ranger.TweenAnimation.TRANSLATE_Y);
    autoScroll.release();
  }

  void _configureHelp() {
    _help = new Ranger.GroupNode.basic();
    _help.visible = false;
    _help.setPosition(-900.0, -250.0);
    addChild(_help, 10, 111);

    Ranger.TextNode key = new Ranger.TextNode.initWith(Ranger.Color4IBlack);
    key.text = "Keys:";
    key.setPosition(0.0, 0.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(A) = Counter Clockwise turning.";
    key.setPosition(0.0, -30.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(Z) = Clockwise turning.";
    key.setPosition(0.0, -60.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(/) = Thrust.";
    key.setPosition(0.0, -90.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "(.) = Fire gun.";
    key.setPosition(0.0, -120.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "1 = zoom 1.0";
    key.setPosition(0.0, -150.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "2 = zoom 2.0";
    key.setPosition(0.0, -180.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "3 = zoom in";
    key.setPosition(0.0, -210.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "4 = zoom out";
    key.setPosition(0.0, -240.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);

    key = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    key.text = "Alt-click to set zoom center (white cross)";
    key.setPosition(0.0, -270.0);
    key.uniformScale = 3.0;
    _help.addChild(key, 10, 111);
  }
  void toggleHelp() {
    _help.visible = !_help.visible;
  }
  
  bool get dampingEnabled => autoScroll.dampingEnabled;
  set dampingEnabled(bool b) {
    autoScroll.dampingEnabled = b;
    
    if (autoScroll.dampingEnabled)
      _messageText.text = "Scroll damping turned on.";
    else
      _messageText.text = "Scroll damping turned off.";
    
    animateMessage();
  }
  
  set textMessage(String msg) => _messageText.text = msg;
  
  void animateMessage() {
    Ranger.Size<double> size = contentSize;
    double hWdith = size.width / 2.0;
    double hHeight = size.height / 2.0;

    Ranger.Application app = Ranger.Application.instance;
    app.animations.stop(_messageText, Ranger.TweenAnimation.TRANSLATE_Y);

    _messageText.setPosition(-hWdith + (hWdith * 0.1), -hHeight - 50.0);

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween popUp = app.animations.moveBy(
        _messageText, 
        0.5,
        100.0, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(popUp)
       ..pushPause(1.0);

    UTE.Tween popDown = app.animations.moveBy(
        _messageText, 
        1.0,
        -100.0, 0.0,
        UTE.Cubic.IN, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    seq..push(popDown);

    seq.start();

  }
  
  void activateShip() {
    GameManager gm = GameManager.instance;

    gm.spikeShip.visible = !gm.spikeShip.visible;
  }
  
  // Should be called when zoom changes.
  void _setViewportAABBox() {
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

    double zValue = 1.0;
    
    // Note: should hold ref to scene instead of searching for it.
    Ranger.GroupingBehavior sceneGB = sm.runningScene as Ranger.GroupingBehavior;
    Ranger.BaseNode layer = sceneGB.getChildByTag(2010);
    if (layer != null) {
      layer.uniformScale = zValue;
    }

    Ranger.Application app = Ranger.Application.instance; 

    // We want the viewport to remain fixed relative to view-space.
    // Hence, if the Layer zooms in we want the viewport to do the
    // opposite.
    // Instead of mapping the viewPort Node into world-space we
    // map app.viewPortAABB to world-space.
    Ranger.DrawContext dc = app.drawContext;
    Ranger.MutableRectangle<double> worldRect = dc.mapViewRectToWorld(app.viewPortAABB);
    //print("worldRect: $worldRect");
    
    // and then for visuals we map the worldRect to the viewPort Node
    // for rendering. The viewPort Node is a centered square.
    Ranger.MutableRectangle<double> nodeRect = convertWorldRectToNode(worldRect);
    //print("nodeRect: $nodeRect");
    //viewPort.scaleTo(nodeRect.width, nodeRect.height);

    worldRect.moveToPool();
    nodeRect.moveToPool();

    app.viewPortWorldAABB.setWith(worldRect);
    
    //print("_zoomChanged: ${app.viewPortWorldAABB}");

    // Mark all Nodes dirty so that their boxes are updated as well.
    rippleDirty();
  }

  void _configOverlay() {
    Ranger.Color4<int> darkBlue = new Ranger.Color4<int>.withRGBA(109~/3, 157~/3, 235~/3, 128);
    _loadingOverlay = new Ranger.OverlayLayer.withColor(darkBlue);
    _loadingOverlay.transparentBackground = false;
    addChild(_loadingOverlay, 20, 555);
    
    Ranger.TextNode loading = new Ranger.TextNode.initWith(Ranger.Color4IOrange);
    loading.text = "Loading...";
    loading.shadows = true;
    loading.setPosition(-150.0, -300.0);
    loading.uniformScale = 8.0;
    _loadingOverlay.addChild(loading, 10, 556);

    Resources resources = GameManager.instance.resources;
    
    Ranger.Application app = Ranger.Application.instance;
    _overlaySpinner = resources.getSpinnerRing(1.5, -360.0, 7001);
    // Track this infinite animation.
    app.animations.track(_overlaySpinner, Ranger.TweenAnimation.ROTATE);

    _loadingOverlay.addChild(_overlaySpinner);
  }  

  void _configureAutoScroll() {
    Ranger.Application app = Ranger.Application.instance;

    Ranger.Size size = contentSize;
    double minS = min(size.width, size.height) / 2.0;
    centerZoneRadius = minS - (minS * 0.5);

//    autoScroll = new TweenAutoScroll.withRadius(centerZoneRadius);
    autoScroll = new SpongyAutoScroll.withRadius(centerZoneRadius);
//    autoScroll = new TightAutoScroll.withRadius(centerZoneRadius);
    addChild(autoScroll.node, 12, 930);
  }

  set autoScrollEnabled(bool b) => autoScroll.autoScrollEnabled = b;
  bool get autoScrollEnabled => autoScroll.autoScrollEnabled;
  
  void toggleScrollZoneVisibility() {
    autoScroll.zone.iconsVisible = !autoScroll.zone.iconsVisible;
    
    if (autoScroll.zone.iconsVisible)
      _messageText.text = "Scroll zone visual turned on";
    else
      _messageText.text = "Scroll zone visual turned off";
    
    animateMessage();
  }
  
  Ranger.Vector2P getHudOriginToGameSpace() {
    GameManager gm = GameManager.instance;
    Ranger.Vector2P worldP = convertToWorldSpace(hudOrigin);
    Ranger.Vector2P gameP = gm.zoomControl.convertWorldToNodeSpace(worldP.v);
    worldP.moveToPool();
    return gameP;
  }
  
  Ranger.Vector2P getHudDelta(Vector2 prevShipPosition, Vector2 currentShipPosition) {
    GameManager gm = GameManager.instance;

    Ranger.Vector2P pw1 = gm.zoomControl.convertToWorldSpace(prevShipPosition);
    Ranger.Vector2P hud1P = convertWorldToNodeSpace(pw1.v);

    Ranger.Vector2P pw2 = gm.zoomControl.convertToWorldSpace(currentShipPosition);
    Ranger.Vector2P hud2P = convertWorldToNodeSpace(pw2.v);

    pw1.moveToPool();
    pw2.moveToPool();
    
    hud1P.v.sub(hud2P.v);
    
    hud2P.moveToPool();
    
    return hud1P;
  }
  
  int _loadImage(String resource, int width, int height, double px, double py, [bool simulateLoadingDelay = false]) {
    Ranger.Application app = Ranger.Application.instance;
    Resources resources = GameManager.instance.resources;

    _loadingCount++;
    
    // Grab current tag prior to bumping.
    int tg = _nextTag;
    
    // I use a Closure to capture the placebo sprite such that it can
    // be used while the actual image is loading.
    (int ntag) {  // <--------- Closure
      // While the actual image is loading, display an animated placebo.
      Ranger.SpriteImage placebo = resources.getSpinner(7000);
      // Track this infinite animation.
      app.animations.track(placebo, Ranger.TweenAnimation.ROTATE);

      placebo.setPosition(px, py);
      addChild(placebo, 10);
      
      // Start loading image
      // This Template example enables Simulated Loading Delay. You
      // wouldn't do this in production. Just leave the parameter missing
      // as it is optional and defaults to "false/disabled".
      //                                         ^-------v
      resources.loadImage(resource, width, height, simulateLoadingDelay).then((ImageElement ime) {
        // Image has finally loaded.
        // Terminate placebo's animation.
        app.animations.flush(placebo);

        // Remove placebo and capture index for insertion of actual image.
        int index = removeChild(placebo);
        
        // Now that the image is loaded we can create a sprite from it.
        Ranger.SpriteImage spri = new Ranger.SpriteImage.withElement(ime);
        // Add the image at the place-order of the placebo.
        addChildAt(spri, index, 10, ntag);
        spri.setPosition(px, py);

        _loadingCount--;
        
        _loadingUpdate(ntag);
      });
    }(tg);// <---- Immediately execute the Closure.
    
    _nextTag++;
    
    return tg;
  }

  void _loadingUpdate(int tag) {
    if (tag == _listTag) {
      // The sprite associated with the tag has now loaded and been added
      // to the scene graph when the Future completed in the Closure; see
      // _loadImage() for the Closure.
      _listSprite = getChildByTag(_listTag);
      _listSprite.uniformScale = 1.5;
    }
    
    // Have all the assets loaded.
    if (_loadingCount == 0) {
      enableMouse = true;
      enableInputs();
      
      Ranger.Application app = Ranger.Application.instance;
      app.animations.flush(_overlaySpinner);
      
      // All sprites have loaded. Remove overlay.
      // I specify "true" because this Layer Node isn't needed ever again.
      //              ^--------------v
      removeChild(_loadingOverlay, true);
      _loaded = true;
    }
  }

}
