part of unittests;

class SpritesScene extends Ranger.AnchoredScene {
  double pauseFor = 0.0;
  Ranger.Color4<int> startColor;
  Ranger.Color4<int> endColor;

  SpritesScene.withPrimary(Ranger.Layer primary, [int zOrder = 0, int tag = 0, Function completeVisit = null]) {
    initWithPrimary(primary, zOrder, tag);
    completeVisitCallback = completeVisit;
  }
  
  SpritesScene([Function completeVisit = null]) {
    completeVisitCallback = completeVisit;
  }

  void backgroundGradient(Ranger.Color4<int> start, Ranger.Color4<int> end) {
    startColor = start;
    endColor = end;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    SpritesLayer layer = new SpritesLayer.basic(true);
    layer.startColor = startColor.toString();
    layer.endColor = endColor.toString();
    layer.tag = 509;
    initWithPrimary(layer);

  }
  
}
