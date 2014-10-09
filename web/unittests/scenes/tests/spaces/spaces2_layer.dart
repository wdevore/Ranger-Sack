part of unittests;

/**
 * Shows the mouse's location relative to different nodes.
 * 
 */
class Spaces2Layer extends Ranger.BackgroundLayer {
  CanvasGradient _gradient;

  Ranger.SpriteImage _home;
  
//  GridNode _grid;
  
  Ranger.TextNode _layerCoords;
  Ranger.TextNode _hudCoords;
  Ranger.TextNode _pointCoords;
  Ranger.TextNode _viewCoords;
  
  String startColor;
  String endColor;
  
  PointColor _pointColorNode;

  Ranger.GroupNode _subGroup;

  
  Spaces2Layer();
 
  factory Spaces2Layer.basic([bool centered = true, int width, int height]) {
    Spaces2Layer layer = new Spaces2Layer();
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

//    _grid = new GridNode.withDimensions(app.designSize.width, app.designSize.height, true);
    
    _configure();

    return true;
  }
  
  @override
  void onEnter() {
    enableMouse = true;
    enableKeyboard = true;
    
    super.onEnter();
  }
  
  @override
  bool onMouseDown(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_home, event.offset.x, event.offset.y);
    nodeP.moveToPool();

    if (_home.containsPoint(nodeP.v)) {
      app.sceneManager.popScene();
      return true;
    }
    
    return true;
  }
  
  @override
  bool onKeyDown(KeyboardEvent event) {
    //print("key onKeyDown ${event.keyCode}");
    GameManager gm = GameManager.instance;

    switch (event.keyCode) {
      case 49: //1
        gm.subGroupNode.uniformScale = gm.subGroupNode.uniformScale + 0.25;
        gm.hud2layer.remap();
        return true;
      case 50: //2
        gm.subGroupNode.uniformScale = gm.subGroupNode.uniformScale - 0.25;
        gm.hud2layer.remap();
        return true;
    }
    
    return false;
  }

  @override
  bool onMouseMove(MouseEvent event) {
    Ranger.Application app = Ranger.Application.instance;

    double textLayerOffset = -40.0;
    double textLocalOffset = -65.0;
    
    Ranger.Vector2P subP = app.drawContext.mapViewToNode(_subGroup, event.offset.x, event.offset.y);
    _layerCoords.text = "SubGroup (${subP.v.x.toStringAsFixed(2)}, ${subP.v.y.toStringAsFixed(2)})";

    Ranger.Vector2P layerP = app.drawContext.mapViewToNode(this, event.offset.x, event.offset.y);
    _layerCoords.setPosition(layerP.v.x, layerP.v.y + textLayerOffset);

    _viewCoords.text = "View (${event.offset.x}, ${event.offset.y})";
    _viewCoords.setPosition(layerP.v.x - 180.0, layerP.v.y - 40.0);

    GameManager gm = GameManager.instance;

    Ranger.Vector2P hudP = app.drawContext.mapViewToNode(gm.hud2layer, event.offset.x, event.offset.y);
    _hudCoords.text = "Hud (${hudP.v.x.toStringAsFixed(2)}, ${hudP.v.y.toStringAsFixed(2)})";
    _hudCoords.setPosition(layerP.v.x - 180.0, layerP.v.y - 70.0);

    Ranger.Vector2P pointP = app.drawContext.mapViewToNode(_pointColorNode, event.offset.x, event.offset.y);
    _pointCoords.text = "Point (${pointP.v.x.toStringAsFixed(2)}, ${pointP.v.y.toStringAsFixed(2)})";
    _pointCoords.setPosition(layerP.v.x + 40.0, layerP.v.y - 70.0);
    
    // We move the layerP object to the pool last. If we move it to soon
    // it will be recycled during the nodeP allocation. So we "hold" on
    // it until the end.
    layerP.moveToPool();
    hudP.moveToPool();
    pointP.moveToPool();
    subP.moveToPool();
    
    if (event.altKey) {
      Ranger.Application app = Ranger.Application.instance;
      // Use "this" when mapping the position
      // Use "_zoomControl" when mapping the scaleCenter.
      Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(_subGroup, event.offset.x, event.offset.y);
      _pointColorNode.position = nodeP.v;
      nodeP.moveToPool();
      return true;
    }

    return true;
  }

  // Note: this isn't calculating correctly when rotations are present.
  void _setParentLabel(Vector2 layer, Ranger.Node node, int mx, int my) {
//    Ranger.Application app = Ranger.Application.instance;
//    Ranger.AffineTransform at = node.calcScaleRotationComponents();
//    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(node, mx, my);
//    at.ApplyToVectorPoint(nodeP.v);
//    _parentCoords.text = "Parent (${nodeP.v.x.toStringAsFixed(2)}, ${nodeP.v.y.toStringAsFixed(2)})";
//    _parentCoords.setPosition(layer.x, layer.y - 90.0);
//    nodeP.moveToPool();
//    at.moveToPool();
  }
  
  bool _setLocalLabel(Vector2 layer, Ranger.Node node, int mx, int my, double offX, double offY, String name) {
    Ranger.Application app = Ranger.Application.instance;

    Ranger.Vector2P nodeP = app.drawContext.mapViewToNode(node, mx, my);
    nodeP.moveToPool();
    
    // TODO Argh! this type casting needs to fixed at the node level.
    if (node is Ranger.SpriteImage) {
      if (node.containsPoint(nodeP.v)) {
        _hudCoords.text = "Local (${nodeP.v.x.toStringAsFixed(2)}, ${nodeP.v.y.toStringAsFixed(2)})";
        _hudCoords.setPosition(layer.x + offX, layer.y + offY);
        return true;
      }
    }
    else if (node is Ranger.CanvasSprite) {
      if (node.containsPoint(nodeP.v)) {
        _hudCoords.text = "Local (${nodeP.v.x.toStringAsFixed(2)}, ${nodeP.v.y.toStringAsFixed(2)})";
        _hudCoords.setPosition(layer.x + offX, layer.y + offY);
        return true;
      }
    }
    
    return false;
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

//    _grid.majorColor = Ranger.color4IFromHex("#512a44").toString();
//    _grid.minorColor = Ranger.color4IFromHex("#d5c2d8").toString();
//    
//    addChild(_grid, 9, 343);
    
    _pointColorNode = new PointColor.initWith(Ranger.Color4ILightBlue, Ranger.Color4IWhite);
    _subGroup.addChild(_pointColorNode, 11, 704);
    _pointColorNode.setPosition(10.0, 10.0);
    _pointColorNode.uniformScale = 10.0;
//    _pointColorNode.setPosition(100.0, 100.0);
    _pointColorNode.visible = true;

    gm.sourceNode = _pointColorNode;
    
    //---------------------------------------------------------------
    // Create text nodes.
    //---------------------------------------------------------------
    Ranger.TextNode title = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    title.text = "Space Mappings 2";
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

    _layerCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _layerCoords.text = "";
    _layerCoords.font = "monaco";
    _layerCoords.shadows = false;
    _layerCoords.uniformScale = 2.0;
    addChild(_layerCoords, 10, 222);
    
    _hudCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _hudCoords.text = "";
    _hudCoords.font = "monaco";
    _hudCoords.shadows = false;
    _hudCoords.uniformScale = 2.0;
    addChild(_hudCoords, 10, 223);
    
    _pointCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _pointCoords.text = "";
    _pointCoords.font = "monaco";
    _pointCoords.shadows = false;
    _pointCoords.uniformScale = 2.0;
    addChild(_pointCoords, 10, 224);
    
    _viewCoords = new Ranger.TextNode.initWith(Ranger.Color4IWhite);
    _viewCoords.text = "";
    _viewCoords.font = "monaco";
    _viewCoords.shadows = false;
    _viewCoords.uniformScale = 2.0;
    addChild(_viewCoords, 10, 225);
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
