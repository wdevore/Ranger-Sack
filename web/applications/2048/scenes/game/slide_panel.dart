part of twenty48;

/**
 * 
 */
class SlidePanel extends Ranger.GroupNode with UTE.Tweenable {
  static const int TWEEN_TRANSLATE_X = 1;
  static const int TWEEN_TRANSLATE_Y = 2;
  static const int TWEEN_FADE = 3;

  RoundRectangle _background;
  bool _activated = false;
  double _height;
  double _width;
  Ranger.Layer _parent;
  Vector2 _dockPosition = new Vector2.zero();
  
  List<ButtonWidget> _buttons = new List<ButtonWidget>();
  
  static const int ACTION_NONE = 0;
  static const int ACTION_CLICKED = 1;
  static const int ACTION_HIDDEN = 2;
  static const int ACTION_REVEALED = 3;
  
  /// Default [ACTION_NONE]
  int action = ACTION_NONE;
  
  String id;
  
  /// Default 1.0 seconds.
  double fadeInDuration = 1.0;
  /// Default 1.0
  double visibilityDuration = 1.0;
  /// Default false
  bool fadeBackgroundOnly = false;
  /// Default 255
  int maxFadeInAlpha = 255;
  
  SlidePanel.basic(Ranger.Layer container, Ranger.Color4<int> backgroundColor, double width, double height, double cornerRadius, [int zOrder = 100, bool centered = true]) {
    _parent = container;
    _width = width;
    _height = height;
    _background = new RoundRectangle.initWith(backgroundColor, width, height, cornerRadius, centered);
    addChild(_background);
    visible = false;
    container.addChild(this, zOrder);
  }

  set dockPosition(Vector2 p) => _dockPosition.setFrom(p);
  bool get active => _activated;
  RoundRectangle get background => _background;
  
  set opacity(num a) {
    int alpha = a.toInt();
    _background.color.a = alpha;
    
    if (fadeBackgroundOnly)
      return;
    
    for(Ranger.BaseNode bn in _background.children) {
      if (bn is Ranger.TextNode) {
        bn.opacity = alpha;
      }
    }
    // Update any Buttons
    for(ButtonWidget bw in _buttons) {
      bw.opacity = alpha;
    }
  }

  num get opacity => _background.color.a;
  
  void toggle() {
    _activated = !_activated;

    if (_activated) {
      visible = true;
      position = _dockPosition; 
      //setPosition(0.0, -(_height / 2.0 + _parent.contentSize.height / 2.0));
      
      // Show
      UTE.Tween moveBy = new UTE.Tween.to(this, TWEEN_TRANSLATE_X, 0.25)
        ..targetRelative = [_width]
        ..easing = UTE.Sine.OUT;
      Ranger.Application.instance.animations.add(moveBy);
    }
    else {
      // Hide
      UTE.Tween moveBy = new UTE.Tween.to(this, TWEEN_TRANSLATE_X, 0.25)
        ..targetRelative = [-_width]
        ..callback = _hideAnimationComplete
        ..callbackTriggers = UTE.TweenCallback.COMPLETE
        ..easing = UTE.Sine.IN;
      Ranger.Application.instance.animations.add(moveBy);
    }
  }
  
  void toggleFade() {
    _activated = true;

    visible = true;
    opacity = 0;
    position = _dockPosition; 

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween fadeIn = new UTE.Tween.to(this, TWEEN_FADE, fadeInDuration)
      ..targetValues = [maxFadeInAlpha]
      ..callback = _fadeInAnimationComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..easing = UTE.Quad.OUT;
    
    seq.push(fadeIn);
    seq.pushPause(visibilityDuration);

    UTE.Tween fadeOut = new UTE.Tween.to(this, TWEEN_FADE, fadeInDuration)
      ..targetValues = [0]
      ..callback = _fadeOutAnimationComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..easing = UTE.Quad.OUT;
    seq.push(fadeOut);

    Ranger.Application.instance.animations.add(seq);
  }
  
  void fadeIn() {
    _activated = true;

    visible = true;
    opacity = 0;
    position = _dockPosition; 

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween fadeIn = new UTE.Tween.to(this, TWEEN_FADE, fadeInDuration)
      ..targetValues = [maxFadeInAlpha]
      ..callback = _fadeInAnimationComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..easing = UTE.Quad.OUT;
    seq.push(fadeIn);
    
    Ranger.Application.instance.animations.add(seq);
  }
  
  void fadeOut() {
    position = _dockPosition; 

    UTE.Timeline seq = new UTE.Timeline.sequence();
    
    UTE.Tween fadeOut = new UTE.Tween.to(this, TWEEN_FADE, fadeInDuration)
      ..targetValues = [0]
      ..callback = _fadeOutAnimationComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..easing = UTE.Quad.OUT;
    seq.push(fadeOut);
    
    Ranger.Application.instance.animations.add(seq);
  }
  
  /**
   * [x] an [y] are in view-space.
   */
  bool isOn(int x, int y) {
    Ranger.Vector2P nodeP = Ranger.Application.instance.drawContext.mapViewToNode(_background, x, y);
    nodeP.moveToPool();

    bool contains = _background.pointInside(nodeP.v);
    
    if (contains) {
      //print("id: $id");
      action = ACTION_CLICKED;
      Ranger.Application.instance.eventBus.fire(this);
    }
    
    return contains;
  }
  
  @override
  bool pointInside(Vector2 p) {
    return _background.pointInside(p);
  }

  void _fadeInAnimationComplete(int type, UTE.BaseTween source) {
    action = ACTION_REVEALED;
    Ranger.Application.instance.eventBus.fire(this);
  }

  void _fadeOutAnimationComplete(int type, UTE.BaseTween source) {
    _activated = false;
    action = ACTION_HIDDEN;
    visible = false;
    Ranger.Application.instance.eventBus.fire(this);
  }

  void _hideAnimationComplete(int type, UTE.BaseTween source) {
    action = ACTION_HIDDEN;
    visible = false;
    Ranger.Application.instance.eventBus.fire(this);
  }
  
  void addNode(Ranger.Node node) {
    _background.addChild(node);
  }
  
  void addButtonWidget(ButtonWidget button) {
    _buttons.add(button);
    addNode(button.node);
  }
  
  int getTweenableValues(UTE.Tween tween, int tweenType, List<num> returnValues) {
    switch(tweenType) {
      case TWEEN_TRANSLATE_Y:
        returnValues[0] = position.y;
        return 1;
      case TWEEN_TRANSLATE_X:
        returnValues[0] = position.x;
        return 1;
      case TWEEN_FADE:
        returnValues[0] = opacity;
        return 1;
    }
    
    return 0;
  }
  
  void setTweenableValues(UTE.Tween tween, int tweenType, List<num> newValues) {
    switch(tweenType) {
      case TWEEN_TRANSLATE_Y:
        setPosition(position.y, newValues[0]);
        break;
      case TWEEN_TRANSLATE_X:
        setPosition(newValues[0], position.y);
        break;
      case TWEEN_FADE:
        opacity = newValues[0];
        break;
    }
  }

}