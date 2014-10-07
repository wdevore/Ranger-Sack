part of template7;

/**
 */
class GameLayer extends Ranger.BackgroundLayer {

  GameLayer();
 
  factory GameLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    GameLayer layer = new GameLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    layer.showOriginAxis = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
    }
    
    return true;
  }
  
}
