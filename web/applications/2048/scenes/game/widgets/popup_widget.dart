part of twenty48;

/**
 * A text area (DIV) with a [ButtonWidget].
 */
class PopupWidget {
  Ranger.Node _background;
  Ranger.TextNode _caption;
  
  bool _overState = false;
  bool _overPrevState = false;
  
  String id;
  
  Ranger.GroupNode _group;
  
  PopupWidget.basic(Ranger.Color4<int> backgroundColor, 
      Ranger.Color4<int> foregroundColor, 
      double width, double height,
      String text,
      String buttonCaption, double cornerRadius) {
    _group = new Ranger.GroupNode();
    
    _background = new RoundRectangle.initWith(backgroundColor, width, height, cornerRadius);
    
    _group.addChild(_background);
    
  }
  
  Ranger.GroupNode get node => _group;
  
  set bindTo(Ranger.Layer layer) => layer.addChild(_group);
  
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
    _background.scaleX = x;
    _background.scaleY = y;
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
    Ranger.Vector2P nodeP = Ranger.Application.instance.drawContext.mapViewToNode(_background, x, y);
    nodeP.moveToPool();

    bool contains = _background.pointInside(nodeP.v);
    
    _overPrevState = _overState;
    _overState = contains;
    
    if (_overState) {
      //print("id: $id");
      Ranger.Application.instance.eventBus.fire(this);
    }
    
    return _overState;
  }
}