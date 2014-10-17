part of template7;

/**
 */
class SplashLayer extends Ranger.BackgroundLayer {
  Ranger.SpriteImage _loadingSpinner;
  Ranger.Scene replacementScene;

  SplashLayer();
 
  factory SplashLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    SplashLayer layer = new SplashLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      Ranger.Application app = Ranger.Application.instance;

      // We need to register the SpriteImage class so that the
      // Universal Tween Engine (UTE) recognizes the class.
      UTE.Tween.registerAccessor(Ranger.SpriteImage, app.animations);
      
      _configure();
    }
    
    return true;
  }
  
  @override
  void onExit() {
    super.onExit();
    
    Ranger.Application app = Ranger.Application.instance;
    app.animations.flushAll();
  }
  
  void _configure() {
    Ranger.Size size = contentSize;
    double hWidth = size.width / 2.0;
    double hHeight = size.height / 2.0;
    
    _addText(hWidth, hHeight);

    _addRangerVersion(hWidth, hHeight);

    _loadResources();
  }

  void _addText(double hw, double hh) {
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "Loading..."
        ..font = "10px fantasy"
        ..shadows = true
        ..setPosition(-50.0, 0.0)
        ..uniformScale = 2.5;
    addChild(line1, 10, 702);
  }

  void _addRangerVersion(double hw, double hh) {
    Ranger.TextNode version = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue)
        ..text = "${Ranger.CONFIG.ENGINE_NAME} ${Ranger.CONFIG.ENGINE_VERSION}"
        ..setPosition(-hw + (hw * 0.05), -hh + (hh * 0.05))
        ..uniformScale = 1.5;
    addChild(version, 10, 703);
  }
  
  void _loadResources() {
    Resources resources = GameManager.instance.resources;
    
    // First get the spinner up and animating.
    Ranger.Application app = Ranger.Application.instance;
    _loadingSpinner = resources.getSpinnerRing(1.5, -360.0, 7001);
    _loadingSpinner.uniformScale = 0.8;
    // Track this infinite animation.
    app.animations.track(_loadingSpinner, Ranger.TweenAnimation.ROTATE);

    addChild(_loadingSpinner);

    // Async load resources for the first level.
    resources.loadLevel0().then((_) {
      // Resources have loaded.
      Ranger.Application app = Ranger.Application.instance;
      // Stop any previous animations; especially infinite ones.
      app.animations.flushAll();
      
      // Transition to EntryScene. Note: may want to use a fancier transition.
      Ranger.TransitionScene transition = new Ranger.TransitionInstant.initWithScene(replacementScene);
      transition.pauseFor = 0.0;
      
      // We "replace" the splash scene because we will never return to it.
      // Pushing it would have suspended the scene keeping it in memory and
      // wasting resources. By replacing it we essentially reclaim resources.
      Ranger.SceneManager sm = Ranger.Application.instance.sceneManager;
      sm.replaceScene(transition);
    });
  }

}
