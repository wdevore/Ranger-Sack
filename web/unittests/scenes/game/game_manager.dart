part of unittests;

class GameManager {
  static final GameManager _instance = new GameManager._internal();

  GameManager._internal();
  
  Resources _resources = new Resources();
  
  Ranger.BaseNode sourceNode;
  AudioLayer space2layer;
  Hud2Layer hud2layer;
  Ranger.GroupNode groupNode;
  Ranger.GroupNode subGroupNode;
  
  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static GameManager get instance => _instance;

  Resources get resources => _resources;
  bool get isBootResourcesReady => resources.isBootResourcesReady;
  bool get isBaseResourcesReady => resources.isBaseResourcesReady;

  Future bootInit() {
    return _resources.loadBootResources();
  }
  
  Future baseInit() {
    return _resources.loadBaseResources();
  }
}
