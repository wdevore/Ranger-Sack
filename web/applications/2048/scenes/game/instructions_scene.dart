part of twenty48;

class InstructionsScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  InstructionsLayer _primaryLayer;
  Ranger.GroupNode _group;
  
  InstructionsScene([int tag = 0]) {
    this.tag = tag;
  }
  
  InstructionsScene.withPrimary(Ranger.Node primary, [Ranger.Scene replacementScene, Function completeVisit]) {
    initWithPrimary(primary);
    _replacementScene = replacementScene;
  }
  
  @override
  bool init([int width, int height]) {
    if (super.init()) {
      // I use a GroupNode in case we want to add a HUD layer.
      _group = new Ranger.GroupNode();
      initWithPrimary(_group);
    
      _primaryLayer = new InstructionsLayer.withColor(Ranger.Color4IBlack, true);
      addLayer(_primaryLayer, 0, 2010);
    }    
    return true;
  }
  
  @override
  void onEnter() {
    super.onEnter();

    // We set the position because a Transition may have changed it during
    // an animation.
    setPosition(0.0, 0.0);
  }
  
}
