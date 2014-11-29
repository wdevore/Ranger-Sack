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

  Ranger.AudioEffects audio;
  int shipBulletSound;
  int triangleHitSound;
  int dualCellHitSound;
  int tinySquareHitSound;
  int bigCircleHitSound;
  int rocketThrustSound;
  
  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static GameManager get instance => _instance;

  void init() {
    _ship = new TriangleShip.basic();
    spikeShip = new SpikeShip.basic();
    _gameLayer = new GameLayer.withColor(Ranger.color4IFromHex("#666666"), true);
    _hudLayer = new HudLayer.asTransparent(true);
    
    audio = new Ranger.AudioEffects.basic(new AudioContext());
  }
  
  Resources get resources => _resources;
  bool get isBootResourcesReady => resources.isBootResourcesReady;
  bool get isBaseResourcesReady => resources.isBaseResourcesReady;

  TriangleShip get triShip => _ship;
  GameLayer get gameLayer => _gameLayer;
  HudLayer get hudLayer => _hudLayer;
}
