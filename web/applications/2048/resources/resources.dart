part of twenty48;

/**
 * Async resources
 */
class Resources {
  ImageElement spinner2;
  ImageElement arrow_left;
  ImageElement arrow_up;
  
  int _resourceCount = 0;
  int _resourceTotal = 0;

  Store gameStore;
  /*
   * Map state = {
   *   "Score" : score,
   *   "Best" : best,
   *   "MaxTile" : maxTile
   * };
   */
  Map _state;
  
  Completer _loadingWorker;

  Resources() {
    spinner2 = new ImageElement(
        src: Ranger.BaseResources.svgMimeHeader + Ranger.BaseResources.spinner2,
        width: 512, height: 512);
    
    // Get ref to storage
    gameStore = new Store("2048Database", "2048Storage");
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

  bool get isLoaded => _resourceCount == _resourceTotal; 

  Future load() {
    // 2 images + storage = 3
    _resourceTotal = 3;
    
    _loadingWorker = new Completer();

    // Enables Simulated Loading Delay. You
    // wouldn't do this in production. Just leave the parameter missing
    // as it is optional and defaults to "false/disabled".
    //                                      ^------v
    loadImage("resources/arrow-left.svg", 32, 32, true).then((ImageElement ime) {
      arrow_left = ime;
      _updateLoadStatus();
    });

    loadImage("resources/arrow-up.svg", 32, 32, true).then((ImageElement ime) {
      arrow_up = ime;
      _updateLoadStatus();
    });

    // Load Storage
    gameStore.open().then((_) {
      gameStore.getByKey("State").then((Map value) {
        if (value == null) {
          print("Missing prior state. Loading default.");
          value = {
            "Score" : 0,
            "Best" : 0,
            "MaxTile" : 2048
          };
        }

        _state = new Map.from(value);
        print("Loaded state: $_state");
        
        _updateLoadStatus();
      });
    });

    return _loadingWorker.future;
  }
  
  int get score => _state["Score"] as int;
  set score(int s) => _state["Score"] = s;
  
  int get best => _state["Best"] as int;
  set best(int s) => _state["Best"] = s;
  
  int get maxTile => _state["MaxTile"] as int;
  set maxTile(int s) => _state["MaxTile"] = s;
  
  void _updateLoadStatus() {
    _resourceCount++;

    if (isLoaded) {
      print("Resources loaded.");
      _loadingWorker.complete();
    }
  }
  
  void save() {
    print("Saving state: $_state");
    gameStore.save(_state, "State");
  }
}