part of unittests;

class AudioScene extends Ranger.AnchoredScene {
  double pauseFor = 0.0;
  Ranger.Color4<int> startColor;
  Ranger.Color4<int> endColor;

  Ranger.GroupNode _group;
  Hud2Layer _hudLayer;

  AudioScene.withPrimary(Ranger.Layer primary, [int zOrder = 0, int tag = 0, Function completeVisit = null]) {
    initWithPrimary(primary, zOrder, tag);
    completeVisitCallback = completeVisit;
  }
  
  AudioScene([Function completeVisit = null]) {
    completeVisitCallback = completeVisit;
  }

  void backgroundGradient(Ranger.Color4<int> start, Ranger.Color4<int> end) {
    startColor = start;
    endColor = end;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    GameManager gm = GameManager.instance;

    _group = new Ranger.GroupNode.basic();
    gm.groupNode = _group;  // This is basically a psuedo root.
    _group.tag = 2011;
    initWithPrimary(_group);

    AudioLayer layer = new AudioLayer.basic(true);
    gm.space2layer = layer;
    layer.startColor = startColor.toString();
    layer.endColor = endColor.toString();
    addLayer(layer, 0, 509);
  }
  
}
