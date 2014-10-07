part of template7;

/**
 */
class EntryLayer extends Ranger.BackgroundLayer {
  Ranger.TextNode _shiftingTextNode;
  
  Ranger.SpriteImage _skull;
  
  ButtonWidget _playButton;
  ButtonWidget _instructionsButton;
  
  bool _configured = false;
  
  EntryLayer();
 
  factory EntryLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    EntryLayer layer = new EntryLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      initGroupingBehavior(this);
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
    
    _stopAllAnimations();
  }
  
  // Stop any infinite animations. Otherwise they linger even after the Layer has
  // disappeared.
  void _stopAllAnimations() {
    Ranger.Application app = Ranger.Application.instance;
    app.animations.stop(_shiftingTextNode, Ranger.TweenAnimation.TRANSLATE_X);
    app.animations.stop(_skull, Ranger.TweenAnimation.ROTATE);
    app.animations.stop(_playButton.node, Ranger.TweenAnimation.ROTATE);
    app.animations.stop(_instructionsButton.node, Ranger.TweenAnimation.ROTATE);
  }
  
  void _resetNodes() {
    _playButton.node.rotationByDegrees = 0.0;
    _instructionsButton.node.rotationByDegrees = 0.0;
    _skull.rotationByDegrees = -5.0;

    Ranger.Size size = contentSize;
    double hHeight = size.height / 2.0;

    _shiftingTextNode.setPosition(-110.0, hHeight - (hHeight * 0.20));
  }
  
  void _configure() {
    Ranger.Size size = contentSize;
    double hWidth = size.width / 2.0;
    double hHeight = size.height / 2.0;
    
    _addTitle(hWidth, hHeight);
    
    _addSkull();
    
    _addText(hWidth, hHeight);
    
    _addButtons(hWidth, hHeight);
    
    _configured = true;
  }

  void _resume() {
    _animateShiftText();
    _animateSkull();
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
  
  void _addSkull() {
    _skull = new Ranger.SpriteImage.withElement(GameManager.instance.resources.skullAndBones);
    _skull..opacity = 0
          ..uniformScale = 0.5
          ..rotationByDegrees = -5.0
          ..setPosition(0.0, 50.0);
    addChild(_skull);
    
    _animateSkull();
  }
  
  void _animateSkull() {
    Ranger.Application app = Ranger.Application.instance;

    UTE.BaseTween fadeIn = app.animations.fadeIn(
        _skull,
        7.0,
        UTE.Cubic.IN);
    
    UTE.BaseTween wobble = app.animations.rotateBy(
        _skull,
        5.0,
        10.0,
        UTE.Quad.INOUT,
        null,
        false);
    
    wobble..repeatYoyo(UTE.Tween.INFINITY, 0.0)
          ..start();
  }
  
  void _addText(double hw, double hh) {
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "You drank the water and now you have gone mad."
        ..font = "10px fantasy"
        ..setPosition(-hw + (hw * 0.30), 100.0)
        ..uniformScale = 2.5;
    addChild(line1, 10, 701);

    Ranger.TextNode line2 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Run around in circles until you passout"
        ..font = "10px fantasy"
        ..setPosition(-hw + (hw * 0.43), 60.0)
        ..uniformScale = 2.5;
    addChild(line2, 10, 701);

    Ranger.TextNode line3 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "and hope you wake up with your pride intact."
        ..font = "10px fantasy"
        ..setPosition(-hw + (hw * 0.35), 20.0)
        ..uniformScale = 2.5;
    addChild(line3, 10, 701);
  }

  @override
  bool onMouseDown(MouseEvent event) {
    if (_playButton.isOn(event.offset.x, event.offset.y)) {
      print("play clicked");
      return true;
    }

    if (_instructionsButton.isOn(event.offset.x, event.offset.y)) {
      _stopAllAnimations();
      _resetNodes();
      
      print("instructions clicked");
      InstructionsScene instrScene = new InstructionsScene();
      Ranger.TransitionScene transition = new Ranger.TransitionInstant.initWithScene(instrScene);
      transition.pauseFor = 0.0;
      
      // We "push" the Entry scene because we want to return to it.
      Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
      sm.pushScene(transition);
      return true;
    }
    return false;
  }

  @override
  bool onMouseMove(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;

    _playButton.isOn(event.offset.x, event.offset.y);
    if (_playButton.entered) {
      _wobbleNode(_playButton.node);
      return true;
    }
    if (_playButton.exited) {
      _playButton.node.rotationByDegrees = 0.0;
      app.animations.stop(_playButton.node, Ranger.TweenAnimation.ROTATE);
      return true;
    }

    _instructionsButton.isOn(event.offset.x, event.offset.y);
    
    if (_instructionsButton.entered) {
      _wobbleNode(_instructionsButton.node);
      return true;
    }
    if (_instructionsButton.exited) {
      _instructionsButton.node.rotationByDegrees = 0.0;
      app.animations.stop(_instructionsButton.node, Ranger.TweenAnimation.ROTATE);
      return true;
    }
    return false;
  }

  void _wobbleNode(Ranger.BaseNode node) {
    Ranger.Application app = Ranger.Application.instance;

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.BaseTween wobbleCCW = app.animations.rotateBy(
        node,
        0.5,
        5.0,
        UTE.Quad.INOUT,
        null,
        false);
    
    seq.push(wobbleCCW);
    
    UTE.BaseTween wobbleCW = app.animations.rotateBy(
        node,
        0.5,
        -10.0,
        UTE.Quad.INOUT,
        null,
        false);
    
    wobbleCW.repeatYoyo(10000, 0.0);
    
    seq.push(wobbleCW);
    seq.start();
  }
  
  void _addButtons(double hw, double hh) {
    _playButton = new ButtonWidget.withElement(GameManager.instance.resources.buttonBackground);
    _playButton..bindTo = this
        ..caption = "Play"
        ..font = "10px fantasy"
        ..scale(3.0, 2.0)
        ..scaleCaption(3.0, 3.0)
        ..setCaptionOffset(-29.0, -7.5)
        ..node.setPosition(-hw + (hw * 0.4), -hh + (hh * 0.50));
    
    _instructionsButton = new ButtonWidget.withElement(GameManager.instance.resources.buttonBackground);
    _instructionsButton..bindTo = this
        ..caption = "Instructions"
        ..font = "10px fantasy"
        ..scale(7.0, 2.0)
        ..scaleCaption(3.0, 3.0)
        ..setCaptionOffset(-80.0, -7.5)
        ..node.setPosition(hw - (hw * 0.6), -hh + (hh * 0.50));
  }
}
