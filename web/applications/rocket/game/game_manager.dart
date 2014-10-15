part of ranger_rocket;

class GameManager {
  static final GameManager _instance = new GameManager._internal();

  GameManager._internal();
  
  Resources _resources = new Resources();

  TriangleShip _ship;
  SpikeShip spikeShip;
  
  GameScene gameScene;
  GameLayer _gameLayer;
  HudLayer _hudLayer;
  ZoomGroup zoomControl;

  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static GameManager get instance => _instance;

  void init() {
    _ship = new TriangleShip.basic();
    spikeShip = new SpikeShip.basic();
    _gameLayer = new GameLayer.withColor(Ranger.color4IFromHex("#666666"), true);
    _hudLayer = new HudLayer.asTransparent(true);
  }
  
  Resources get resources => _resources;
  bool get isBootResourcesReady => resources.isBootResourcesReady;
  bool get isBaseResourcesReady => resources.isBaseResourcesReady;

  Future bootInit() {
    return _resources.loadBootResources();
  }
  
  Future baseInit() {
    return _resources.loadBaseResources();
  }

  TriangleShip get triShip => _ship;
  GameLayer get gameLayer => _gameLayer;
  HudLayer get hudLayer => _hudLayer;
}
