part of template7;

class SplashScene extends Ranger.AnchoredScene {
  /**
   * How long to pause (in seconds) before transitioning to the [_replacementScene]
   * [Scene]. Default is immediately (aka 0.0)
   */
  double pauseFor = 0.0;
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
  }
}