part of twenty48;

class Tile extends Ranger.GroupNode with UTE.Tweenable, Ranger.Color4Mixin {
  static const int TWEEN_SCALE = 1;
  static const int TWEEN_TRANSLATE = 2;
  
  int fieldPosition = -1;
  double cornerRadius = 0.02;
  Ranger.TextNode _number;
  int _value = 0;
  
  Math.Random _randGen = new Math.Random();

  bool mergedThisRound = false;
  
  // ----------------------------------------------------------
  // Poolable support and Factory
  // ----------------------------------------------------------
  Tile();
  
  Tile._();
  factory Tile.pooled() {
    Tile poolable = new Ranger.Poolable.of(Tile, _createPoolable);
    poolable.pooled = true;
    return poolable;
  }

  factory Tile.initWith(Ranger.Color4<int> fillColor) {
    Tile poolable = new Tile.pooled();
    if (poolable.init()) {
      poolable.initWithColor(fillColor);
      poolable.initWithUniformScale(poolable, 1.0);
      return poolable;
    }
    return null;
  }
  
  static Tile _createPoolable() => new Tile._();

  @override
  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
      //_value = (_randGen.nextInt(2) + 1) * 2;
      mergedThisRound = false;
      return true;
    }
    
    return false;
  }

//  void addNumber(double x, double y, double scale, Ranger.Color4<int> color) {
  void addNumber(Ranger.Color4<int> color) {
    _number = new Ranger.TextNode.initWith(color)
        ..text = value.toString()
        ..font = "normal 900 10px Arial"
        ..shadows = true;
    addChild(_number, 10, 780);
    _align(_value);
  }

  set value(int v) {
    _value = v;
    _align(v);
    _number.text = v.toString();
  }
  
  int get value => _value;
  
  void _align(int v) {
    if (v == 0) {
      // zero
      _number..setPosition(-1.7/10.0, -1.7/10.0)
          ..uniformScale = 0.055;
    }
    else if (v < 10) {
      // single digit
      _number..setPosition(-1.7/10.0, -1.7/10.0)
          ..uniformScale = 0.055;
    }
    else if (v > 9 && v < 100) {
      // two digits
      _number..setPosition(-3.4/10.0, -1.7/10.0)
          ..uniformScale = 0.055;
    }
    else if (v > 99 && v < 1000) {
      // three digits
      _number..setPosition(-4.0/10.0, -1.5/10.0)
          ..uniformScale = 0.045;
    }
    else if (v > 999 && v < 10000) {
      // four digits
      _number..setPosition(-4.1/10.0, -1.1/10.0)
          ..uniformScale = 0.035;
    }
    else if (v > 9999 && v < 100000) {
      // five digits
      _number..setPosition(-4.3/10.0, -1.0/10.0)
          ..uniformScale = 0.03;
    }
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

  @override
  void draw(Ranger.DrawContext context) {
    context.save();

    CanvasRenderingContext2D context2D = context.renderContext as CanvasRenderingContext2D;

    context2D.beginPath(); 

    context2D.fillStyle = color.toString();
    
    _roundedRect(context2D, -0.5, -0.5, 1.0, 1.0, cornerRadius);

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
   
}
