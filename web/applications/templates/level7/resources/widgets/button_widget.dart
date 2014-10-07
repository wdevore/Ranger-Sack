part of template7;

/**
 * 
 */
class ButtonWidget {
  Ranger.SpriteImage _image;
  Ranger.TextNode _caption;
  
  bool _overState = false;
  bool _overPrevState = false;
  
  Ranger.GroupNode _group;
  
  ButtonWidget.withElement(ImageElement ime) {
    _group = new Ranger.GroupNode();
    _image = new Ranger.SpriteImage.withElement(ime);
    //_image.aabboxVisible = true;
    _group.addChild(_image);
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
    _image.scaleX = x;
    _image.scaleY = y;
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
    Ranger.Vector2P nodeP = Ranger.Application.instance.drawContext.mapViewToNode(_image, x, y);
    nodeP.moveToPool();

    bool contains = _image.containsPoint(nodeP.v);
    _overPrevState = _overState;
    _overState = contains;
    
    return _overState;
  }
}