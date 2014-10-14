part of twenty48;

/**
 */
class InstructionsLayer extends Ranger.BackgroundLayer {
  Ranger.TextNode _shiftingTextNode;
  
  ButtonWidget _backButton;
  
  bool _configured = false;
  
  InstructionsLayer();
 
  factory InstructionsLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    InstructionsLayer layer = new InstructionsLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      Ranger.Application app = Ranger.Application.instance;

      UTE.Tween.registerAccessor(Ranger.TextNode, app.animations);
      UTE.Tween.registerAccessor(Ranger.GroupNode, app.animations);
    }
    
    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    
    super.onEnter();
    
    if (!_configured) {
      // We perform the configure here in onEnter() instead of init()
      // Attempting to configure during init() will fail because resources
      // haven't been loaded yet.
      _configure();
    }
    else {
      // We could be arriving here when the user clicked the back button
      // on the instructions scene.
      _resume();
    }
  }
  
  @override
  void onExit() {
    super.onExit();
    
    // Stop any infinite animations. Otherwise they linger even after the Layer has
    // disappeared.
    Ranger.Application app = Ranger.Application.instance;
    _stopAllAnimations();
  }
  
  void _configure() {
    Ranger.Size size = contentSize;
    double hWidth = size.width / 2.0;
    double hHeight = size.height / 2.0;
    
    _addTitle(hWidth, hHeight);
    
    _addButtons(hWidth, hHeight);
    
    _configured = true;
  }

  void _resume() {
    _animateShiftText();
  }
  
  void _stopAllAnimations() {
    Ranger.Application app = Ranger.Application.instance;
    app.animations.stop(_shiftingTextNode, Ranger.TweenAnimation.TRANSLATE_X);
    app.animations.stop(_backButton.node, Ranger.TweenAnimation.ROTATE);
  }

  void _resetNodes() {
    _backButton.node.rotationByDegrees = 0.0;

    Ranger.Size size = contentSize;
    double hHeight = size.height / 2.0;

    _shiftingTextNode.setPosition(-110.0, hHeight - (hHeight * 0.20));
  }
  
  void _addTitle(double hw, double hh) {
    _shiftingTextNode = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _shiftingTextNode..text = "Crazy"
          ..font = "10px fantasy"
          ..setPosition(-110.0, hh - (hh * 0.20))
          ..uniformScale = 3.0;
    addChild(_shiftingTextNode, 10, 701);

    _animateShiftText();

    Ranger.TextNode islands = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Scene"
        ..font = "10px fantasy"
        ..setPosition(15.0, hh - (hh * 0.20))
        ..uniformScale = 3.0;
    addChild(islands, 10, 701);
  }
  
  void _animateShiftText() {
    Ranger.Application app = Ranger.Application.instance;
    
    // Animate the "Shifting" word left and right
    UTE.BaseTween leftRight = app.animations.moveTo(
        _shiftingTextNode,
        2.0,
        -100.0, 0.0,
        UTE.Sine.INOUT, Ranger.TweenAnimation.TRANSLATE_X,
        null,
        false);
    
    leftRight..repeatYoyo(UTE.Tween.INFINITY, 0.0)
             ..start();
  }
  
  void _addText(double hw, double hh) {
  }

  @override
  bool onMouseDown(MouseEvent event) {
    if (_backButton.isOn(event.offset.x, event.offset.y)) {
      _stopAllAnimations();
      _resetNodes();
      Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
      sm.popScene();
      return true;
    }
    return false;
  }

  @override
  bool onMouseMove(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;

    _backButton.isOn(event.offset.x, event.offset.y);
    if (_backButton.entered) {
      _wobbleNode(_backButton.node);
      return true;
    }
    if (_backButton.exited) {
      _backButton.node.rotationByDegrees = 0.0;
      app.animations.stop(_backButton.node, Ranger.TweenAnimation.ROTATE);
      return true;
    }
    return false;
  }

  void _wobbleNode(Ranger.BaseNode node) {
    Ranger.Application app = Ranger.Application.instance;

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.BaseTween wobbleCCW = app.animations.rotateBy(
        node,
        1.0,
        5.0,
        UTE.Quad.INOUT,
        null,
        false);
    
    seq.push(wobbleCCW);
    
    UTE.BaseTween wobbleCW = app.animations.rotateBy(
        node,
        1.0,
        -10.0,
        UTE.Quad.INOUT,
        null,
        false);
    
    wobbleCW.repeatYoyo(10000, 0.0);
    
    seq.push(wobbleCW);
    seq.start();
  }
  
  void _addButtons(double hw, double hh) {
    _backButton = new ButtonWidget.withElement(GameManager.instance.resources.buttonBackground);
    _backButton..bindTo = this
        ..caption = "Back"
        ..font = "10px fantasy"
        ..scale(3.0, 2.0)
        ..scaleCaption(3.0, 3.0)
        ..setCaptionOffset(-33.0, -7.5)
        ..node.setPosition(0.0, -hh + (hh * 0.30));
  }
}
