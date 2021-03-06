part of unittests;

class KeyboardScene extends Ranger.AnchoredScene {
  double pauseFor = 0.0;
  Ranger.Color4<int> startColor;
  Ranger.Color4<int> endColor;

  KeyboardScene.withPrimary(Ranger.Layer primary, [int zOrder = 0, int tag = 0, Function completeVisit = null]) {
    initWithPrimary(primary, zOrder, tag);
    completeVisitCallback = completeVisit;
  }
  
  KeyboardScene([Function completeVisit = null]) {
    completeVisitCallback = completeVisit;
  }

  void backgroundGradient(Ranger.Color4<int> start, Ranger.Color4<int> end) {
    startColor = start;
    endColor = end;
  }
  
  @override
  bool init([int width, int height]) {
    if (super.init()) {
    }    
    return true;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    KeyboardLayer layer = new KeyboardLayer.basic(true);
    layer.startColor = startColor.toString();
    layer.endColor = endColor.toString();
    layer.tag = 609;
    initWithPrimary(layer);
  }
  
}
