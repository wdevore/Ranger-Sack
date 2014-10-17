part of twenty48;

class RoundRectangle extends Ranger.GroupNode with UTE.Tweenable, Ranger.Color4Mixin {
  static const int TWEEN_SCALE = 1;
  static const int TWEEN_TRANSLATE = 2;
  
  double cornerRadius = 1.0;
  double width;
  double height;
  double cornerX = 0.0;
  double cornerY = 0.0;
  bool centered = true;
  
  Aabb2 _aabbox = new Aabb2();

  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  RoundRectangle();
  
  RoundRectangle._();
  factory RoundRectangle.pooled() {
    RoundRectangle poolable = new Ranger.Poolable.of(RoundRectangle, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory RoundRectangle.initWith(Ranger.Color4<int> fillColor, double width, double height, double cornerRadius, [bool centered = true]) {
    RoundRectangle poolable = new RoundRectangle.pooled();
    if (poolable.init()) {
      poolable.initWithColor(fillColor);
      poolable.width = width;
      poolable.height = height;
      poolable.centered = centered;
      if (centered) {
        poolable.cornerX = -width / 2.0;
        poolable.cornerY = -height / 2.0;
      }
      poolable.cornerRadius = cornerRadius;
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    return null;
  }
  
  static RoundRectangle _createPoolable() => new RoundRectangle._();

  @override
  bool init() {
    if (super.init()) {
      return true;
    }
    
    return false;
  }

  int getTweenableValues(UTE.Tween tween, int tweenType, List<num> returnValues) {
    switch(tweenType) {
      case TWEEN_SCALE:
        returnValues[0] = uniformScale;
        return 1;
      case TWEEN_TRANSLATE:
        returnValues[0] = position.x;
        returnValues[1] = position.y;
        return 2;
    }
    
    return 0;
  }
  
  void setTweenableValues(UTE.Tween tween, int tweenType, List<num> newValues) {
    switch(tweenType) {
      case TWEEN_SCALE:
        uniformScale = newValues[0];
        break;
      case TWEEN_TRANSLATE:
        setPosition(newValues[0], newValues[1]);
        break;
    }
  }

  /**
   * [p] should be in node's local-space.
   */
  @override
  bool pointInside(Vector2 p) {
    return localBounds.containsVector2(p);
  }

  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

    context2D.beginPath(); 

    context2D.fillStyle = color.toString();
    
    _roundedRect(context2D, cornerX, cornerY, width, height, cornerRadius);

    context2D.fill();

    context.restore();
  }

  void _roundedRect(CanvasRenderingContext2D context, num cornerX, num cornerY, num width, num height, num cornerRadius) { 
    if (width > 0) 
      context.moveTo(cornerX + cornerRadius, cornerY); 
    else
      context.moveTo(cornerX - cornerRadius, cornerY);
    
    context.arcTo(cornerX + width, cornerY, cornerX + width, cornerY + height, cornerRadius); 
    context.arcTo(cornerX + width, cornerY + height, cornerX, cornerY + height, cornerRadius); 
    context.arcTo(cornerX, cornerY + height, cornerX, cornerY, cornerRadius);
    
    if (width > 0) { 
      context.arcTo(cornerX, cornerY, cornerX + cornerRadius, cornerY, cornerRadius);
    } 
    else { 
      context.arcTo(cornerX, cornerY, cornerX - cornerRadius, cornerY, cornerRadius);
    }
  }
   
  Aabb2 get localBounds {
    _aabbox.min.setValues(cornerX, cornerY);
    _aabbox.max.setValues(cornerX + width, cornerY + height);
    return _aabbox;
  }

}
