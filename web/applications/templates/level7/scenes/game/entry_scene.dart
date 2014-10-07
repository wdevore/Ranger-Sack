part of template7;

class EntryScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  EntryLayer _primaryLayer;
  Ranger.GroupNode _group;
  
  EntryScene([int tag = 0]) {
    this.tag = tag;
  }
  
  EntryScene.withPrimary(Ranger.Node primary, [Ranger.Scene replacementScene, Function completeVisit]) {
    initWithPrimary(primary);
    _replacementScene = replacementScene;
  }
  
  @override
  bool init([int width, int height]) {
    if (super.init()) {
      
      // I use a GroupNode in case we want to add a HUD layer.
      _group = new Ranger.GroupNode();
      initWithPrimary(_group);
    
      _primaryLayer = new EntryLayer.withColor(Ranger.Color4IBlack, true);
//      _primaryLayer = new EntryLayer.withColor(Ranger.color4IFromHex("#ffffff"), true);
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
