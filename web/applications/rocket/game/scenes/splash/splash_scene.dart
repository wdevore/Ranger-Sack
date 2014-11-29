part of ranger_rocket;

class SplashScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  
  SplashScene.withPrimary(Ranger.Layer primary, Ranger.Scene replacementScene, [Function completeVisit = null]) {
    initWithPrimary(primary);
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }

  SplashScene.withReplacementScene(Ranger.Scene replacementScene, [Function completeVisit = null]) {
    tag = 101010;
    completeVisitCallback = completeVisit;
    _replacementScene = replacementScene;
  }
  
  @override
  void onEnter() {
    super.onEnter();

    SplashLayer splashLayer = new SplashLayer.withColor(Ranger.color4IFromHex("#aa8888"), true);
    initWithPrimary(splashLayer);

    splashLayer.beforeResourcesLoaded();
    
    // Async load resources for the first level.
    GameManager.instance.resources.load().then((_) {
      splashLayer.resourcesLoaded();
      transitionEnabled = true;
    });

  }
  
  @override
  void transition() {
    Ranger.TransitionScene transition = new Ranger.TransitionMoveInFrom.initWithDurationAndScene(0.5, _replacementScene, Ranger.TransitionMoveInFrom.FROM_LEFT);
    transition.tag = 9090;
    
    Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
    sm.replaceScene(transition);
  }

}
