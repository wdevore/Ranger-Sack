part of ranger_rocket;

/*
  */
class Resources {
  ImageElement rangerLogo;

  static const int BASE_ICON_SIZE = 32;
  
  ImageElement spinner;
  ImageElement spinner2;
  
  // Sound effects.
  String asteroidShooter;
  String airNoise;
  String explosionRing;
  String forceFieldHit;
  String triggerExplode;
  String rocketThrust;
  
  int _resourceCount = 0;
  int _resourceTotal = 0;

  /// Loaded icons are centered automatically.
  bool autoCenter = true;
  
  Completer _baseWorker;

  Function _loadedCallback;

  bool _bootInitialized = false;
  bool _baseInitialized = false;
  
  bool get isBootResourcesReady => _bootInitialized;
  bool get isBaseResourcesReady => _baseInitialized;
  
  Resources() {
    // These spinners are embedded resources so they are always available.
    spinner = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner,
        width: 32, height: 32);

    spinner2 = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner2,
        width: 512, height: 512);
  }

  Future load() {
    _resourceTotal++; // Asteroid sound
    _resourceTotal++; // airNoise sound
    _resourceTotal++; // explosionRing sound
    _resourceTotal++; // forceFieldHit sound
    _resourceTotal++; // triggerExplode sound
    _resourceTotal++; // rocketThrust sound
    _resourceTotal++; // Splash image

    _baseWorker = new Completer();

    _load();
    //new Future.delayed(new Duration(milliseconds: 2000), _load);
    
    return _baseWorker.future;
  }
  
  void _load() {
    _loadBaseImage((ImageElement ime) {rangerLogo = ime;}, "resources/RangerDart.png", 960, 540);

    HttpRequest.getString("resources/ClassicAsteroidShooter.rsfxr").then((effect){
      asteroidShooter = effect;
      _onBaseComplete();
    });
    HttpRequest.getString("resources/AirNoise.rsfxr").then((effect){
      airNoise = effect;
      _onBaseComplete();
    });
    HttpRequest.getString("resources/ExplosionRing.rsfxr").then((effect){
      explosionRing = effect;
      _onBaseComplete();
    });
    HttpRequest.getString("resources/ForceFieldHit.rsfxr").then((effect){
      forceFieldHit = effect;
      _onBaseComplete();
    });
    HttpRequest.getString("resources/TriggerExplode.rsfxr").then((effect){
      triggerExplode = effect;
      _onBaseComplete();
    });
    HttpRequest.getString("resources/RocketThrust.rsfxr").then((effect){
      rocketThrust = effect;
      _onBaseComplete();
    });
  }
  
  Future<ImageElement> loadImage(String source, int iWidth, int iHeight, [bool simulateLoadingDelay = false]) {
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.simulateLoadingDelay = simulateLoadingDelay;
    return loader.load(iWidth, iHeight);
  }
  
  void _loadBaseImage(Ranger.ImageLoaded loaded, String source, int iWidth, int iHeight) {
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.load(iWidth, iHeight).then((ImageElement ime) {
      loaded(ime);
      _onBaseComplete();
    });
  }
  
  void _onBaseComplete() {
    _resourceCount++;
    _checkForCompleteness();
  }

  bool get isBaseLoaded => _resourceCount == _resourceTotal; 
  void _checkForCompleteness() {
    if (isBaseLoaded) {
      _baseInitialized = true;
      _baseWorker.complete();
    }
  }

  Ranger.SpriteImage getSpinner(int tag) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.SpriteImage si = new Ranger.SpriteImage.withElement(spinner);
    si.tag = tag;
    
    UTE.Tween rot = app.animations.rotateBy(
        si, 
        1.5,
        -360.0, 
        UTE.Linear.INOUT, null, false);
    //                 v---------^
    // Above we set "autostart" to false in order to set the repeat value
    // because you can't change the value after the tween has started.
    rot..repeat(UTE.Tween.INFINITY, 0.0)
       ..start();
    
    return si;
  }
  
  /**
   * [lapTime] how long to make one rotation/arc of the given [deltaDegrees].
   */
  Ranger.SpriteImage getSpinnerRing(double lapTime, double deltaDegrees, int tag) {
    Ranger.Application app = Ranger.Application.instance;
    Ranger.SpriteImage si = new Ranger.SpriteImage.withElement(spinner2);
    si.tag = tag;
    
    UTE.Tween rot = app.animations.rotateBy(
        si, 
        lapTime,
        deltaDegrees, 
        UTE.Linear.INOUT, null, false);
    //                 v---------^
    // Above we set "autostart" to false in order to set the repeat value
    // because you can't change the value after the tween has started.
    rot..repeat(UTE.Tween.INFINITY, 0.0)
       ..start();
    
    return si;
  }

}