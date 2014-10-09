part of unittests;

class Spaces2Scene extends Ranger.AnchoredScene {
  double pauseFor = 0.0;
  Ranger.Color4<int> startColor;
  Ranger.Color4<int> endColor;

  Ranger.GroupNode _group;
  Hud2Layer _hudLayer;

  Spaces2Scene.withPrimary(Ranger.Layer primary, [int zOrder = 0, int tag = 0, Function completeVisit = null]) {
    initWithPrimary(primary, zOrder, tag);
    completeVisitCallback = completeVisit;
  }
  
  Spaces2Scene([Function completeVisit = null]) {
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

    Spaces2Layer layer = new Spaces2Layer.basic(true);
    gm.space2layer = layer;
    layer.startColor = startColor.toString();
    layer.endColor = endColor.toString();
    addLayer(layer, 0, 509);

    //---------------------------------------------------------------
    // A layer that overlays on top of the game layer. For example, FPS.
    //---------------------------------------------------------------
    _hudLayer = new Hud2Layer.asTransparent(true);
    gm.hud2layer = _hudLayer;
    addLayer(_hudLayer, 0, 2012);

  }
  
}
