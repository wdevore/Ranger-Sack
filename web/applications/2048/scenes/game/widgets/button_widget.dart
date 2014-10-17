part of twenty48;

/**
 * 
 */
class ButtonWidget extends Ranger.Color4Mixin {
  Ranger.Node _node;
  Ranger.TextNode _caption;
  
  bool _overState = false;
  bool _overPrevState = false;
  
  String id;
  
  Ranger.GroupNode _group;
  
  ButtonWidget.withElement(ImageElement ime) {
    _group = new Ranger.GroupNode();
    _node = new Ranger.SpriteImage.withElement(ime);
    //Ranger.SpriteImage si = _node as Ranger.SpriteImage;
    //si.aabboxVisible = true;
    _group.addChild(_node);
  }
  
  ButtonWidget.withNode([Ranger.Node node]) {
    _group = new Ranger.GroupNode();
    if (node == null)
      _node = new RoundRectangle.initWith(Ranger.Color4IBlue, 70.0, 30.0, 5.0);
    else
      _node = node;
    //_image.aabboxVisible = true;
    _group.addChild(_node);
  }
  
  ButtonWidget.basic(Ranger.Color4<int> color, double width, double height, double cornerRadius, [bool centered = true]) {
    _group = new Ranger.GroupNode();
    _node = new RoundRectangle.initWith(color, width, height, cornerRadius, centered);
    _group.addChild(_node);
  }
  
  Ranger.GroupNode get node => _group;
  
//  @override
//  int get opacity {
//    return changingColor.a;
//  }
  
  @override
  set opacity(int opacity) {
    color.a = opacity;
    
    if (_node is RoundRectangle) {
      RoundRectangle rr = _node as RoundRectangle;
      rr.color.a = color.a;
    }
    
    _caption.color.a = color.a;
  }

  set backgroundColor(Ranger.Color4<int> color) {
    if (_node is RoundRectangle) {
      RoundRectangle rr = _node as RoundRectangle;
      rr.color.setWith(color);
    }
  }
  
  set bindTo(Ranger.GroupingBehavior group) => group.addChild(_group);
  
  set caption(String c) {
    if (_caption == null) {
      _caption = new Ranger.TextNode.initWith(Ranger.Color4IBlack);
      _group.addChild(_caption);
    }
    
    _caption.text = c;
  }
  
  set captionColor(Ranger.Color4<int> c) {
    if (_caption == null) {
      _caption = new Ranger.TextNode.initWith(Ranger.Color4IBlack);
      _group.addChild(_caption);
    }
    
    _caption.color = c;
  }
  
  set font(String f) {
    if (_caption == null) {
      _caption = new Ranger.TextNode.initWith(Ranger.Color4IBlack);
      _group.addChild(_caption);
    }
    
    _caption.font = f;
  }
  
  void setCaptionOffset(double x, double y) {
    _caption.setPosition(x, y);
  }
  
  void scale(double x, double y) {
    _node.scaleX = x;
    _node.scaleY = y;
  }
  
  void scaleCaption(double x, double y) {
    _caption.scaleX = x;
    _caption.scaleY = y;
  }
  
  bool get entered => _overState && !_overPrevState;
  bool get exited => !_overState && _overPrevState;
  
  /**
   * [x] an [y] are in view-space.
   */
  bool isOn(int x, int y) {
    Ranger.Vector2P nodeP = Ranger.Application.instance.drawContext.mapViewToNode(_node, x, y);
    nodeP.moveToPool();

    bool contains = _node.pointInside(nodeP.v);
    
    _overPrevState = _overState;
    _overState = contains;
    
    if (_overState) {
      //print("id: $id");
      Ranger.Application.instance.eventBus.fire(this);
    }
    
    return _overState;
  }
}