part of twenty48;

class GameManager {
  static final GameManager _instance = new GameManager._internal();

  Resources _resources = new Resources();
  
  Tile scoreTile;
  Tile bestTile;
  Grid grid;

  GameManager._internal() {
    Ranger.Application.instance.unloadCallback = unload;
  }
  
  // ----------------------------------------------------------
  // Instance
  // ----------------------------------------------------------
  static GameManager get instance => _instance;

  Resources get resources => _resources;
  
  void reset() {
    score = 0;
    best = 0;
    maxTile = 2048;
    save();
  }
  
  void resetScore() {
    score = 0;
    save();
  }
  
  set score(int value) {
    _resources.score = value;
    scoreTile.value = value;
  }
  
  int get score => _resources.score;
  
  set best(int value) {
    _resources.best = value;
    bestTile.value = value;
  }
  
  int get best => _resources.best;
  
  set maxTile(int value) {
    _resources.maxTile = value;
  }
  
  int get maxTile => _resources.maxTile;
  
  void save() {
    _resources.save();
  }
  
  void unload() {
    // Save scores and config.
    save();
  }
}
