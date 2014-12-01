part of unittests;

/**
 * Shows the mouse's location relative to different nodes.
 * 
 */
class AudioLayer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  
  Ranger.TextNode _layerCoords;
  Ranger.TextNode _hudCoords;
  Ranger.TextNode _pointCoords;
  Ranger.TextNode _viewCoords;
  
  String startColor;
  String endColor;
  
  // Asteroid shooter effect
  RectangleNode _asteroidNode;
  int _asteroidSound;
  
  RectangleNode _computerNode;
  int computer;
  RectangleNode _compSignalNode;
  int compSignal;
  RectangleNode _fieldDownNode;
  int fieldDown;
  RectangleNode _forceFieldNode;
  int forceField;
  RectangleNode _warbleNode;
  int warble;
  RectangleNode _hallNode;
  int hall;
  RectangleNode _machineGunNode;
  int machineGun;
  RectangleNode _phaserNode;
  int phaser;
  RectangleNode _shooterNode;
  int shooter;
  RectangleNode _starTrekNode;
  int starTrek;
  RectangleNode _transporterNode;
  int transporter;
  RectangleNode _ufolandingNode;
  int ufolanding;

  Ranger.GroupNode _subGroup;

  Ranger.AudioEffects _ae;
  
  AudioLayer();
 
  factory AudioLayer.basic([bool centered = true, int width, int height]) {
    AudioLayer layer = new AudioLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.showOriginAxis = true;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    super.init(width, height);

    _home = new Ranger.SpriteImage.withElement(GameManager.instance.resources.home);

    Ranger.Application app = Ranger.Application.instance;
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    _ae = new Ranger.AudioEffects.basic(new AudioContext());
    _asteroidSound = _ae.loadEffect(GameManager.instance.resources.asteroidShooter);
    computer = _ae.loadEffect(GameManager.instance.resources.computer);
    compSignal = _ae.loadEffect(GameManager.instance.resources.compSignal);
    fieldDown = _ae.loadEffect(GameManager.instance.resources.fieldDown);
    forceField = _ae.loadEffect(GameManager.instance.resources.forceField);
    warble = _ae.loadEffect(GameManager.instance.resources.warble);
    hall = _ae.loadEffect(GameManager.instance.resources.hall);
    machineGun = _ae.loadEffect(GameManager.instance.resources.machineGun);
    phaser = _ae.loadEffect(GameManager.instance.resources.phaser);
    shooter = _ae.loadEffect(GameManager.instance.resources.shooter);
    starTrek = _ae.loadEffect(GameManager.instance.resources.starTrek);
    transporter = _ae.loadEffect(GameManager.instance.resources.transporter);
    ufolanding = _ae.loadEffect(GameManager.instance.resources.ufolanding);
    
    _configure();

    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    
    super.onEnter();
  }
  
  @override
  bool onMouseDown(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_home.pointInside(nodeP.v)) {
      app.sceneManager.popScene();
      return true;
    }

    if (_iconClicked(_asteroidNode, event.offset.x, event.offset.y)) {
      _ae.play(_asteroidSound);
      return true;
    }
    if (_iconClicked(_computerNode, event.offset.x, event.offset.y)) {
      _ae.play(computer);
      return true;
    }
    if (_iconClicked(_compSignalNode, event.offset.x, event.offset.y)) {
      _ae.play(compSignal);
      return true;
    }
    if (_iconClicked(_fieldDownNode, event.offset.x, event.offset.y)) {
      _ae.play(fieldDown);
      return true;
    }
    if (_iconClicked(_forceFieldNode, event.offset.x, event.offset.y)) {
      _ae.play(forceField);
      return true;
    }
    if (_iconClicked(_warbleNode, event.offset.x, event.offset.y)) {
      _ae.play(warble);
      return true;
    }
    if (_iconClicked(_hallNode, event.offset.x, event.offset.y)) {
      _ae.play(hall);
      return true;
    }
    if (_iconClicked(_machineGunNode, event.offset.x, event.offset.y)) {
      _ae.play(machineGun);
      return true;
    }
    if (_iconClicked(_phaserNode, event.offset.x, event.offset.y)) {
      _ae.play(phaser);
      return true;
    }
    if (_iconClicked(_shooterNode, event.offset.x, event.offset.y)) {
      _ae.play(shooter);
      return true;
    }
    if (_iconClicked(_starTrekNode, event.offset.x, event.offset.y)) {
      _ae.play(starTrek);
      return true;
    }
    if (_iconClicked(_transporterNode, event.offset.x, event.offset.y)) {
      _ae.play(transporter);
      return true;
    }
    if (_iconClicked(_ufolandingNode, event.offset.x, event.offset.y)) {
      _ae.play(ufolanding);
      return true;
    }
    
    return true;
  }
  
  bool _iconClicked(RectangleNode node, int x, int y) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(node, x, y);
    nodeP.moveToPool();

    if (node.pointInside(nodeP.v)) {
      return true;
    }
    
    return false;
  }
  
  @override
  bool onMouseMove(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;

    return true;
  }

  @override
  void onExit() {
    super.onExit();

    Ranger.Application app = Ranger.Application.instance;
    app.animations.tweenMan.killTarget(_home, Ranger.TweenAnimation.TRANSLATE_Y);
  }

  void _configure() {
    Ranger.Application app = Ranger.Application.instance;
    GameManager gm = GameManager.instance;

    double hHeight = app.designSize.height / 2.0;
    double hWidth = app.designSize.width / 2.0;
    double hGap = hWidth - (hWidth * 0.25);
    double vGap = hHeight - (hHeight * 0.25);
    
    addChild(_home, 10, 120);
    _home.uniformScale = 3.0;
    _home.setPosition(hGap, vGap);

    _subGroup = new Ranger.GroupNode.basic();
    gm.subGroupNode = _subGroup;
    addChild(_subGroup, 10);
    _subGroup.tag = 2040;
    _subGroup.iconVisible = true;
    _subGroup.iconScale = 10.0;
    _subGroup.uniformScale = 5.0;

    _asteroidNode = new RectangleNode.basic();
    double x = -400.0;
    _addEffect(x, 200.0, _asteroidNode, "Asteroids", -0.6, -0.75);
    _computerNode = new RectangleNode.basic();
    x += 120.0;
    _addEffect(x, 200.0, _computerNode, "ComputerCalc", -0.6, -0.75);
    _compSignalNode = new RectangleNode.basic();
    x += 140.0;
    _addEffect(x, 200.0, _compSignalNode, "ComputerSig", -0.6, -0.75);
    _fieldDownNode = new RectangleNode.basic();
    x += 130.0;
    _addEffect(x, 200.0, _fieldDownNode, "FieldDown", -0.6, -0.75);
    _forceFieldNode = new RectangleNode.basic();
    x += 120.0;
    _addEffect(x, 200.0, _forceFieldNode, "ForceField", -0.6, -0.75);
    _warbleNode = new RectangleNode.basic();
    x += 120.0;
    _addEffect(x, 200.0, _warbleNode, "Warbler", -0.6, -0.75);
    _hallNode = new RectangleNode.basic();
    x += 100.0;
    _addEffect(x, 200.0, _hallNode, "Hallucin", -0.6, -0.75);
    _machineGunNode = new RectangleNode.basic();
    x = -400.0;
    _addEffect(x, 80.0, _machineGunNode, "MachineGun", -0.6, -0.75);
    _phaserNode = new RectangleNode.basic();
    x += 130.0;
    _addEffect(x, 80.0, _phaserNode, "Phaser", -0.6, -0.75);
    _shooterNode = new RectangleNode.basic();
    x += 100.0;
    _addEffect(x, 80.0, _shooterNode, "Shooter", -0.6, -0.75);
    _starTrekNode = new RectangleNode.basic();
    x += 130.0;
    _addEffect(x, 80.0, _starTrekNode, "TransporterIn", -0.6, -0.75);
    _transporterNode = new RectangleNode.basic();
    x += 130.0;
    _addEffect(x, 80.0, _transporterNode, "TransporterOut", -0.6, -0.75);
    _ufolandingNode = new RectangleNode.basic();
    x += 160.0;
    _addEffect(x, 80.0, _ufolandingNode, "UfoLanding", -0.6, -0.75);

    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    Ranger.TextNode title = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    title.text = "Audio Effects";
    title.font = "monaco";
    title.shadows = false;
    title.setPosition(-hGap - 0.0, vGap - 90.0);
    title.uniformScale = 2.0;
    addChild(title, 10, 222);

    //---------------------------------------------------------------
    // Begin animating text into view.
    //---------------------------------------------------------------
    // Because the TextNode isn't a Tweenable we need to register the 
    // class with the Tween system in order to recognize and animate it.
    UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    double vertPos = hHeight - (app.designSize.height / 3.0);
    
    UTE.Tween mTw1 = app.animations.moveBy(
        title, 
        1.5,
        vertPos, 0.0,
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_Y, null, false);
    
    seq..push(mTw1)
       ..start();

  }
 
  Ranger.GroupNode _addEffect(double x, double y, RectangleNode node, String title, double tx, double ty) {
    Ranger.GroupNode group = new Ranger.GroupNode.basic();

    Ranger.SpriteImage note = new Ranger.SpriteImage.withElement(GameManager.instance.resources.musicHaut);
    Ranger.TextNode effectName = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    effectName.text = title;
    effectName.setPosition(tx, ty);
    
    node.center();
    node.fillColor = Ranger.Color4IDarkBlue.toString();
    node.drawColor = Ranger.Color4IWhite.toString();
    group.addChild(node, 11, 704);
    group.uniformScale = 75.0;
    note.uniformScale = 1.0/group.uniformScale * 2.0;
    effectName.uniformScale = 1.0/group.uniformScale * 2.0;
    group.setPosition(x, y);
    group.addChild(note, 11, 705);
    group.addChild(effectName, 11, 706);
    addChild(group, 10, 222);
    
    return group;
  }
  
  @override
  void drawBackground(Ranger.DrawContext context) {
    if (!transparentBackground) {
      CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

      Ranger.Size<double> size = contentSize;
      context.save();

      if (_gradient == null) {
        _gradient = context2D.createLinearGradient(0.0, size.height * 3.0, size.width, size.height);
        _gradient.addColorStop(0.0, startColor);
        _gradient.addColorStop(1.0, endColor);
      }

      context2D..fillStyle = _gradient
          ..fillRect(0.0, 0.0, size.width, size.height);

      
      Ranger.Application.instance.objectsDrawn++;
      
      context.restore();
    }
  }

}
