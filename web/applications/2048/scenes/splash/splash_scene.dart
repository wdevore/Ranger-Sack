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
    
    SplashLayer splashLayer = new SplashLayer.withColor(Ranger.color4IFromHex("#9e978e"), true);
    initWithPrimary(splashLayer);
    splashLayer.replacementScene = _replacementScene;
  }
}