part of ranger_rocket;

/**
 * Show Ranger-Dart logo
 * animate "Rocket Dart" in from bottom.
 * animate "Version 0.0.1" in from bottom delayed by a fraction of second.
 */
class SplashLayer extends Ranger.BackgroundLayer {
  Ranger.SpriteImage _loadingSpinner;
  Ranger.TextNode _loadingText;
  
  Ranger.SpriteImage _spriteLogo;
  Ranger.TextNode _rocketText;
  Ranger.TextNode _version;
  
  SplashLayer();
  
  factory SplashLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    SplashLayer layer = new SplashLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    layer.tag = 404;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);
    
    Ranger.Application app = Ranger.Application.instance;
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    return true;
  }

  @override
  void onEnter() {
    super.onEnter();

    _setViewportAABBox();

    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    Ranger.Application app = Ranger.Application.instance;

    // Stop previous animation so relative motion doesn't add up causing
    // the target to animate offscreen.
    app.animations.stop(_rocketText, Ranger.TweenAnimation.TRANSLATE_Y);
    app.animations.stop(_version, Ranger.TweenAnimation.TRANSLATE_Y);
    
    unScheduleUpdate();
  }

  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    
    double hHeight = app.designSize.height / 2.0;
    
    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    _rocketText = new Ranger.TextNode.initWith(Ranger.Color4IOrange);
    _rocketText.text = "Rocket Test-o-rama";
    _rocketText.shadows = true;
    _rocketText.setPosition(-500.0, -(hHeight) - 70.0);
    _rocketText.uniformScale = 10.0;
    //_rocketText.strokeColor = Ranger.Color4IBlack;
    //_rocketText.strokeWidth = 0.3;
    addChild(_rocketText, 10, 222);
    
    _version = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue);
    _version.text = "${Ranger.CONFIG.ENGINE_NAME} ${Ranger.CONFIG.ENGINE_VERSION}";
    _version.shadows = true;
    _version.strokeColor = Ranger.Color4IBlack;
    _version.strokeWidth = 0.3;
    _version.setPosition(-610.0, hHeight + 40.0);
    _version.uniformScale = 15.0;
    addChild(_version, 10, 222);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------

    UTE.Timeline par = new UTE.Timeline.parallel();

    UTE.Timeline seq = new UTE.Timeline.sequence();
    seq.pushPause(0.2);
    
    double vertPos = hHeight - (app.designSize.height / 3.0);
    
    UTE.Tween mTw1 = app.animations.moveBy(
        _rocketText, 
        1.0,
        vertPos, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq.push(mTw1);
    par.push(seq);

    UTE.Timeline seq2 = new UTE.Timeline.sequence();
    seq2.pushPause(0.1);
    UTE.Tween mTw2 = app.animations.moveBy(
        _version, 
        1.0,
        -250.0, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq2.push(mTw2);
    par.push(seq2);

    par.start();

  }
  
  // Should be called when zoom changes.
  void _setViewportAABBox() {
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;

    double zValue = 1.0;
    
    // TODO hold ref to scene instead of searching for it.
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

  void beforeResourcesLoaded() {
    Resources resources = GameManager.instance.resources;
    
    // First get the spinner up and animating.
    Ranger.Application app = Ranger.Application.instance;
    _loadingSpinner = resources.getSpinnerRing(1.5, -360.0, 7001);
    _loadingSpinner.uniformScale = 0.3;
    _loadingSpinner.setPosition(100.0, 0.0);
    // Track this infinite animation.
    app.animations.track(_loadingSpinner, Ranger.TweenAnimation.ROTATE);

    _loadingText = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#502b3a"))
        ..text = "Loading"
        ..font = "normal 600 10px Verdana"
        ..setPosition(-430.0, -30.0)
        ..uniformScale = 10.0;
    addChild(_loadingText, 10, 99);

    addChild(_loadingSpinner);
  }

  void resourcesLoaded() {
    // Resources have loaded.
    Ranger.Application app = Ranger.Application.instance;
    // Stop any previous animations; especially infinite ones.
    app.animations.flushAll();

    removeChild(_loadingSpinner);
    removeChild(_loadingText);
    
    _configure();

    //---------------------------------------------------------------
    // Create and load Ranger logo.
    //---------------------------------------------------------------
    _spriteLogo = new Ranger.SpriteImage.withElement(GameManager.instance.resources.rangerLogo);

    addChild(_spriteLogo, 10, 111);
    
    //---------------------------------------------------------------
    // Audio
    //---------------------------------------------------------------
    GameManager gm = GameManager.instance;
    Ranger.AudioEffects audio = gm.audio;
    gm.shipBulletSound = audio.loadEffect(gm.resources.asteroidShooter);
    gm.triangleHitSound = audio.loadEffect(gm.resources.airNoise);
    gm.dualCellHitSound = audio.loadEffect(gm.resources.forceFieldHit);
    gm.tinySquareHitSound = audio.loadEffect(gm.resources.explosionRing);
    gm.bigCircleHitSound = audio.loadEffect(gm.resources.triggerExplode);
    gm.rocketThrustSound = audio.loadEffect(gm.resources.rocketThrust);
  }
  
}
