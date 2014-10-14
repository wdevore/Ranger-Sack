part of twenty48;

class SplashScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  
  SplashScene.withPrimary(Ranger.Layer primary, Ranger.Scene replacementScene, [Function completeVisit = null]) {
    initWithPrimary(primary);
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  SplashScene.withReplacementScene(Ranger.Scene replacementScene, [Function completeVisit = null]) {
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();
    
    SplashLayer splashLayer = new SplashLayer.withColor(Ranger.color4IFromHex("#555555"), true);
    initWithPrimary(splashLayer);
    splashLayer.replacementScene = _replacementScene;
    
    transitionEnabled = true;
  }
  
  @override
  void transition() {
    // Create another GameScene node to transition to.
    GameScene inComingScene = new GameScene();
    
    // TODO UTE parallel animations seem to have an issue with pauses.
    // They always seems to occur at the end instead of where they were
    // placed in sequence.
    Ranger.TransitionScene transition = new Ranger.TransitionSlideIn.initWithDurationAndScene(1.0, inComingScene, Ranger.TransitionSlideIn.FROM_TOP);

    // This will replace the current Scene (aka SplashScene invoked
    // from the GameLayer) with the new transition.
    // When the transition completes the new Scene will at the
    // top of the stack and ready to "run".
    Ranger.Application.instance.sceneManager.replaceScene(transition);
  }
}