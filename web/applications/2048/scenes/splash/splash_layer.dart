part of twenty48;

/**
 */
class SplashLayer extends Ranger.BackgroundLayer {
  Ranger.SpriteImage _loadingSpinner;
  Ranger.Scene replacementScene;

  SplashLayer();
 
  factory SplashLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    SplashLayer layer = new SplashLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      _configure();
    }
    
    return true;
  }
  
  @override
  void onEnter() {
    super.onEnter();
  }
  
  void _configure() {
    Ranger.Size size = contentSize;
    double hWidth = size.width / 2.0;
    double hHeight = size.height / 2.0;
    
    _addText(hWidth, hHeight);

    _addRangerVersion(hWidth, hHeight);
  }

  void _addText(double hw, double hh) {
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "2048"
        ..font = "10px Verdana"
        ..shadows = true
        ..strokeColor = Ranger.Color4IWhite
        ..strokeWidth = 4.0
        ..setPosition(-250.0, -50.0)
        ..uniformScale = 20.0;
    addChild(line1, 10, 702);
  }

  void _addRangerVersion(double hw, double hh) {
    Ranger.TextNode version = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue)
        ..text = "${Ranger.CONFIG.ENGINE_NAME} ${Ranger.CONFIG.ENGINE_VERSION}"
        ..setPosition(-hw + (hw * 0.05), -hh + (hh * 0.05))
        ..uniformScale = 1.5;
    addChild(version, 10, 703);
  }

}
