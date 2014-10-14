part of twenty48;

/**
 * Async resources
 */
class Resources {
  static int _nextTagId = 0;
  
  ImageElement spinner2;
  ImageElement skullAndBones;
  ImageElement buttonBackground;
  
  static const int BASE_ICON_SIZE = 32;
  
  int _resourceCount = 0;
  int _resourceTotal = 0;

  Completer _loadingWorker;

  Resources() {
    spinner2 = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner2,
        width: 512, height: 512);
  }
  
  Future<ImageElement> loadImage(String source, int iWidth, int iHeight, [bool simulateLoadingDelay = false]) {
    Ranger.ImageLoader loader = new Ranger.ImageLoader.withResource(source);
    loader.simulateLoadingDelay = simulateLoadingDelay;
    return loader.load(iWidth, iHeight);
  }
  
  /**
   * This spinner is available immediately.
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

  bool get isLevelLoaded => _resourceCount == _resourceTotal; 

  Future loadLevel0() {
    _resourceTotal = 2;
    
    _loadingWorker = new Completer();

    // Enables Simulated Loading Delay. You
    // wouldn't do this in production. Just leave the parameter missing
    // as it is optional and defaults to "false/disabled".
    //                                         ^-----------------v
    loadImage("resources/Pirate_Skull_And_Bones.svg", 744, 496, true).then((ImageElement ime) {
      skullAndBones = ime;
      _updateLoadStatus();
    });

    loadImage("resources/Button_Background.svg", 32, 32, true).then((ImageElement ime) {
      buttonBackground = ime;
      _updateLoadStatus();
    });

    return _loadingWorker.future;
  }
  
  void _updateLoadStatus() {
    _resourceCount++;
    
    if (isLevelLoaded)
      _loadingWorker.complete();
  }
  
}