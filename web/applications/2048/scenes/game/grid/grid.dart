part of twenty48;

/**
 * Algorithm for this game came from:
 * https://www.makegameswith.us/gamernews/384/build-your-own-2048-with-spritebuilder-and-cocos2d
 */
class Grid {
  static const double TILE_SIZE = 195.0;
  static const int START_TILES = 2;

  static const int GRID_SIZE = 4;
  
  double columnWidth;
  double columnHeight;
  double tileMarginVertical;
  double tileMarginHorizontal;

  List<List<Vector2>> _cells = new List<List<Vector2>>(GRID_SIZE);
  List<List<Tile>> _tiles = new List<List<Tile>>(GRID_SIZE);

  Math.Random _randGen = new Math.Random();

  Tile _gridBackground;
  GameLayer _layer;
  
  /// Total of merged tiles.
//  int total;
  
  // Traditional color set.
//  Map<int, Ranger.Color4<int>> _colors = {
//         2 : Ranger.color4IFromHex("#FFFFFF"),
//         4 : Ranger.color4IFromHex("#FFEEEE"),
//         8 : Ranger.color4IFromHex("#FFDDDD"),
//         16 : Ranger.color4IFromHex("#FFCCCC"),
//         32 : Ranger.color4IFromHex("#FFBBBB"),
//         64 : Ranger.color4IFromHex("#FFAAAA"),
//         128 : Ranger.color4IFromHex("#FF9999"),
//         256 : Ranger.color4IFromHex("#FF8888"),
//         512 : Ranger.color4IFromHex("#FF7777"),
//         1024 : Ranger.color4IFromHex("#FF6666"),
//         2048 : Ranger.color4IFromHex("#FF5555"),
//         4096 : Ranger.color4IFromHex("#FF4444"),
//         8192 : Ranger.color4IFromHex("#FF3333"),
//         16384 : Ranger.color4IFromHex("#FF2222"),
//         32768 : Ranger.color4IFromHex("#FF1111"),
//         65536 : Ranger.color4IFromHex("#FF0000")
//  };

  // Gray scale colors
//  Map<int, Ranger.Color4<int>> _colors = {
//         2 : Ranger.color4IFromHex("#FFFFFF"),
//         4 : Ranger.color4IFromHex("#EEEEEE"),
//         8 : Ranger.color4IFromHex("#DDDDDD"),
//         16 : Ranger.color4IFromHex("#CCCCCC"),
//         32 : Ranger.color4IFromHex("#BBBBBB"),
//         64 : Ranger.color4IFromHex("#AAAAAA"),
//         128 : Ranger.color4IFromHex("#999999"),
//         256 : Ranger.color4IFromHex("#888888"),
//         512 : Ranger.color4IFromHex("#777777"),
//         1024 : Ranger.color4IFromHex("#666666"),
//         2048 : Ranger.color4IFromHex("#555555"),
//         4096 : Ranger.color4IFromHex("#444444"),
//         8192 : Ranger.color4IFromHex("#333333"),
//         16384 : Ranger.color4IFromHex("#222222"),
//         32768 : Ranger.color4IFromHex("#111111"),
//         65536 : Ranger.color4IFromHex("#000000")
//  };

  // Dispersed colors
//  Map<int, Ranger.Color4<int>> _colors = {
//         2 : Ranger.color4IFromHex("#ffffff"),
//         4 : Ranger.color4IFromHex("#ede0c8"),
//         8 : Ranger.color4IFromHex("#f2b179"),
//         16 : Ranger.color4IFromHex("#f59563"),
//         32 : Ranger.color4IFromHex("#f67c5f"),
//         64 : Ranger.color4IFromHex("#f65e3b"),
//         128 : Ranger.color4IFromHex("#94a596"),
//         256 : Ranger.color4IFromHex("#5e7461"),
//         512 : Ranger.color4IFromHex("#3e5d58"),
//         1024 : Ranger.color4IFromHex("#e03c31"),
//         2048 : Ranger.color4IFromHex("#e4002b"),
//         4096 : Ranger.color4IFromHex("#3c3a32"),
//         8192 : Ranger.color4IFromHex("#999999"),
//         16384 : Ranger.color4IFromHex("#666666"),
//         32768 : Ranger.color4IFromHex("#333333"),
//         65536 : Ranger.color4IFromHex("#7474c1")
//  };

  // Ranger earth tones.
  Map<int, Ranger.Color4<int>> _colors = {
         2 : Ranger.color4IFromHex("#ffffff"),
         4 : Ranger.color4IFromHex("#b2a8a2"),
         8 : Ranger.color4IFromHex("#696158"),
         16 : Ranger.color4IFromHex("#5e514d"),
         32 : Ranger.color4IFromHex("#e1b7a7"),
         64 : Ranger.color4IFromHex("#956c58"),
         128 : Ranger.color4IFromHex("#7c4d3a"),
         256 : Ranger.color4IFromHex("#4e3629"),
         512 : Ranger.color4IFromHex("#babd8b"),
         1024 : Ranger.color4IFromHex("#8a8d4a"),
         2048 : Ranger.color4IFromHex("#4e5b31"),
         4096 : Ranger.color4IFromHex("#3d441e"),
         8192 : Ranger.color4IFromHex("#6787b7"),
         16384 : Ranger.color4IFromHex("#385e9d"),
         32768 : Ranger.color4IFromHex("#004b87"),
         65536 : Ranger.color4IFromHex("#253746")
  };

  bool _actionMoveWithMerging = false;
  bool _actionMoving = false;
  bool _actionMerging = false;
  
  /*
   *      3  ^
   * rows 2  |
   *      1  |     
   *      0  ------>
   *         0 1 2 3
   *         columns
   */
  void build(GameLayer layer) {
    _layer = layer;
    double gx = -450.0;
    double gy = -75.0;
    
    _gridBackground = new Tile.initWith(Ranger.color4IFromHex("#a39382"));
    _layer.addChild(_gridBackground, 101, 1000);
    _gridBackground.setPosition(gx, gy);
    _gridBackground.uniformScale = 900.0;

    double scaleRatio = TILE_SIZE / _gridBackground.uniformScale;
    double cellOff = 0.24;
    double x = -0.36;
    double y = -0.36;
    
    for (int col = 0; col < GRID_SIZE; col++) {
      _cells[col] = new List<Vector2>(GRID_SIZE);
      _tiles[col] = new List<Tile>(GRID_SIZE);
      
      for (int row = 0; row < GRID_SIZE; row++) {
        Tile gridCell = new Tile.initWith(Ranger.color4IFromHex("#b7a99a"));
        _gridBackground.addChild(gridCell, 102, 1001);
        
        gridCell.cornerRadius = 0.07;
        gridCell.setPosition(x, y);
        gridCell.uniformScale = scaleRatio;

        _cells[col][row] = gridCell.position;
        
        y += cellOff;
      }
      y = -0.36;
      x += cellOff;
    }
  }
  
  Vector2 get position => _gridBackground.position;
  
  void move(int dx, int dy) {
    bool movedTilesThisRound = false;
    
    // apply negative vector until reaching boundary, this way we get the tile that is the furthest away
    //bottom left corner
    int currentX = 0;
    int currentY = 0;
     
    // Move to relevant edge by applying direction until reaching border
    while (_isIndexValid(currentX, currentY)) {
      int newX = currentX + dx;
      int newY = currentY + dy;
      if (_isIndexValid(newX, newY)) {
        currentX = newX;
        currentY = newY;
      }
      else {
        break;
      }
    }
     
    // store initial row value to reset after completing each column
    int initialY = currentY;
    // define changing of x and y value (moving left, up, down or right?)
    int xChange = -dx;
    int yChange = -dy;
    if (xChange == 0) {
      xChange = 1;
    }
    if (yChange == 0) {
      yChange = 1;
    }
  
    // visit column for column
    while (_isIndexValid(currentX, currentY)) {
      while (_isIndexValid(currentX, currentY)) {
        // get tile at current index
        Tile tile = _tiles[currentX][currentY];
        if (tile == null) {
          // if there is no tile at this index -> skip
          currentY += yChange;
          continue;
        }

        // store index in temp variables to change them and store new location of this tile
        int newX = currentX;
        int newY = currentY;
        // find the farthest position by iterating in direction of the
        // vector until we reach border of grid or an occupied cell
        while (_isIndexValidAndUnoccupied(newX + dx, newY + dy)) {
          newX += dx;
          newY += dy;
        }

        bool performMove = false;
        // If we stopped moving in vector direction, but next index in
        // vector direction is valid, this means the cell is occupied.
        // Let's check if we can merge them
        if (_isIndexValid(newX + dx, newY + dy)) {
          // get the other tile
          int otherTileX = newX + dx;
          int otherTileY = newY + dy;
          Tile otherTile = _tiles[otherTileX][otherTileY];
          // compare value of other tile and also check if the other
          // tile has been merged this round
          if (tile.value == otherTile.value && !otherTile.mergedThisRound) {
            // merge tiles
            _mergeTileAtIndex(currentX, currentY, otherTileX, otherTileY);
            movedTilesThisRound = true;
          } else {
            // we cannot merge so we want to perform a move
            performMove = true;
          }
        } else {
            // we cannot merge so we want to perform a move
            performMove = true;
        }
        
        if (performMove) {
            // Move tile to furthest position
            if (newX != currentX || newY !=currentY) {
              // only move tile if position changed
              _moveTile(tile, currentX, currentY, newX, newY);
              movedTilesThisRound = true;
            }
        }

        // move further in this column
        currentY += yChange;
      }
      
      // move to the next column, start at the inital row
      currentX += xChange;
      currentY = initialY;
    }
    
    _nextRound(movedTilesThisRound);
  }
  
  void spawnStartTiles() {
    for (int i = 0; i < START_TILES; i++) {
      _spawnRandomTile();
    }
  }
  
  // Various test cases.
  void spawnDebug() {
    // Total deadlock
//    _addTile(0, 0, 2);
//    _addTile(1, 0, 4);
//    _addTile(2, 0, 8);
//    _addTile(3, 0, 16);
//    _addTile(0, 1, 32);
//    _addTile(1, 1, 64);
//    _addTile(2, 1, 128);
//    _addTile(3, 1, 256);
//    _addTile(0, 2, 512);
//    _addTile(1, 2, 1024);
//    _addTile(2, 2, 2048);
//    _addTile(0, 3, 8192);
//    _addTile(1, 3, 16384);
//    _addTile(2, 3, 32768);
//    _addTile(3, 3, 65536);
    
    // Partial lock. Used for quickly testing "no moves remaining"
    _addTile(0, 0, 2);
    _addTile(1, 0, 4);
    _addTile(2, 0, 8);
    _addTile(3, 0, 16);
    _addTile(0, 1, 32);
    _addTile(1, 1, 64);
    _addTile(2, 1, 128);
    _addTile(3, 1, 256);
    _addTile(0, 2, 512);
    _addTile(1, 2, 1024);
    _addTile(2, 2, 2);
    _addTile(3, 2, 4096);
    _addTile(0, 3, 2);
    _addTile(1, 3, 2);
    _addTile(2, 3, 2);
    _addTile(3, 3, 2);
  }
  
  void clear() {
    for (int i = 0; i < GRID_SIZE; i++) {
      for (int j = 0; j < GRID_SIZE; j++) {
        Tile tile = _tiles[i][j];
        _gridBackground.removeChild(tile);
        _tiles[i][j] = null;
      }
    }
  }
  
  void _addTile(int col, int row, int value) {
    Tile tile = new Tile.initWith(_colors[value]);
    double scaleRatio = TILE_SIZE / _gridBackground.uniformScale;

    // Use the default uniformScale value
    tile.uniformScale = scaleRatio / 5.0;
    tile.cornerRadius = 0.07;
    tile.addNumber(Ranger.Color4IGoldYellow);
    tile.value = value;
    
    _tiles[col][row] = tile;
    
    _gridBackground.addChild(tile, 102, 2001);
    tile.position = _cells[col][row];
    
    UTE.Tween tw = new UTE.Tween.to(tile, Tile.TWEEN_SCALE, 0.5)
      ..targetValues = [scaleRatio]
      ..easing = UTE.Bounce.OUT;
    Ranger.Application.instance.animations.add(tw);
  }
  
  void _spawnRandomTile([int value]) {
    bool spawned = false;
    while (!spawned) {
      int randomRow = _randGen.nextInt(4);
      int randomColumn = _randGen.nextInt(4);
      bool positionFree = _tiles[randomColumn][randomRow] == null;
      if (positionFree) {
        if (value == null) {
          value = (_randGen.nextInt(2) + 1) * 2;
        }
        _addTile(randomColumn, randomRow, value);
        spawned = true;
      }
    }
  }
  
  bool _isIndexValid(int x, int y) {
    bool indexValid = true;
    indexValid = indexValid && x >= 0;
    indexValid = indexValid && y >= 0;
    if (indexValid) {
      indexValid = indexValid && x < GRID_SIZE;
      if (indexValid) {
        indexValid = indexValid && y < GRID_SIZE;
      }
    }
    return indexValid;
  }
  
  // Keep tiles from overlapping
  bool _isIndexValidAndUnoccupied(int x, int y) {
    bool indexValid = _isIndexValid(x, y);
    if (!indexValid) {
      return false;
    }
    bool unoccupied = _tiles[x][y] == null;
    return unoccupied;
  }
  
  void _nextRound(bool movedTilesThisRound) {
    if (movedTilesThisRound)
      _spawnRandomTile();
    
//    _tiles.forEach(
//        (List<Tile> l) => l.skipWhile(
//            (Tile t) => t == null).forEach(
//                (Tile t) => t.mergedThisRound = false));
    
    // Reset merge flags
    for (int i = 0; i < GRID_SIZE; i++) {
      for (int j = 0; j < GRID_SIZE; j++) {
        Tile tile = _tiles[i][j];
        if (tile != null) {
          // reset merged flag
          tile.mergedThisRound = false;
        }
      }
    }
    
    bool movesAvailable = _movePossible();
    if (!movesAvailable) {
      GridMessage msg = new GridMessage();
      msg.action = GridMessage.ACTION_LOST;
      Ranger.Application.instance.eventBus.fire(msg);
    }
  }
  
  bool _movePossible() {
    for (int i = 0; i < GRID_SIZE; i++) {
      for (int j = 0; j < GRID_SIZE; j++) {
        Tile tile = _tiles[i][j];
        // no tile at this position
        if (tile == null) {
          // move possible, we have a free field
          return true;
        } else {
          // there is a tile at this position. Check if this tile could move
          Tile topNeighbour = _tileForIndex(i, j+1);
          Tile bottomNeighbour = _tileForIndex(i, j-1);
          Tile leftNeighbour = _tileForIndex(i-1, j);
          Tile rightNeighbour = _tileForIndex(i+1, j);
          List<Tile> neighours = [topNeighbour, bottomNeighbour, leftNeighbour, rightNeighbour];
          for (Tile neighbourTile in neighours) {
            if (neighbourTile != null) {
              Tile neighbour = neighbourTile;
              if (neighbour.value == tile.value) {
                return true;
              }
            }
          }
        }
      }
    }
    
    return false;
  }
  
  Tile _tileForIndex(int x, int y) {
    if (!_isIndexValid(x, y)) {
      return null;
    }
    else {
      return _tiles[x][y];
    }
  }
  
  void _moveTile(Tile tile, int oldX, int oldY, int newX, int newY) {
    _actionMoving = true;

    _tiles[newX][newY] = _tiles[oldX][oldY];
    _tiles[oldX][oldY] = null;

    // Animate
    Vector2 toCell = _cells[newX][newY];
    
    UTE.Tween tw = new UTE.Tween.to(tile, Tile.TWEEN_TRANSLATE, 0.25)
      ..targetValues = [toCell.x, toCell.y]
      ..callback = _moveComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..easing = UTE.Sine.OUT;

    Ranger.Application.instance.animations.add(tw);
  }

  void _updateScore(int value) {
    GridMessage msg = new GridMessage();
    msg.mergedValue = value;
    msg.action = GridMessage.ACTION_SCORE_CHANGED;
    
    Ranger.Application.instance.eventBus.fire(msg);
  }
  
  void _mergeTileAtIndex(int x, int y, int xOtherTile, int yOtherTile) {
    // The tile that will disappear off the grid after move.
    Tile mergedTile = _tiles[x][y];
    // The tile that stays on the grid.
    Tile otherTile = _tiles[xOtherTile][yOtherTile];
    
    int total = mergedTile.value + otherTile.value;
    _updateScore(total);
    
    if (total == GameManager.instance.maxTile) {
      GridMessage msg = new GridMessage();
      msg.action = GridMessage.ACTION_WON;
      Ranger.Application.instance.eventBus.fire(msg);
    }

    _tiles[x][y] = null;

    Vector2 otherCell = _cells[xOtherTile][yOtherTile];
    Vector2 mergeCell = _cells[x][y];

    // We set the merged flag here instead of in the callback because we
    // need the flag set "before" the animation is complete. The animation
    // runs async.
    otherTile.mergedThisRound = true;

    _actionMoveWithMerging = true;
    _actionMerging = true;

    // Animate
    UTE.Timeline tl = new UTE.Timeline.parallel();

    UTE.Tween otherTo = new UTE.Tween.to(otherTile, Tile.TWEEN_TRANSLATE, 0.25)
      ..targetValues = [otherCell.x, otherCell.y]
      ..callback = _otherMoveWithMergeComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..userData = otherTile
      ..easing = UTE.Sine.OUT;
    tl.push(otherTo);
    
    UTE.Tween mergeTo = new UTE.Tween.to(mergedTile, Tile.TWEEN_TRANSLATE, 0.25)
      ..targetValues = [otherCell.x, otherCell.y]
      ..callback = _mergeMoveComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE
      ..userData = mergedTile
      ..easing = UTE.Sine.OUT;
    tl.push(mergeTo);
    
    Ranger.Application.instance.animations.add(tl);
  }
  
  void _moveComplete(int type, UTE.BaseTween source) {
    _actionMoving = false;
  }
  
  void _mergeMoveComplete(int type, UTE.BaseTween source) {
    Tile tile = source.userData as Tile;
    _gridBackground.removeChild(tile, true);

    _actionMerging = false;
  }
  
  void _otherMoveWithMergeComplete(int type, UTE.BaseTween source) {
    Tile tile = source.userData as Tile;
    tile.value *= 2;
    tile.color = _colors[tile.value];

    _actionMoveWithMerging = false;
  }
  
  bool actionsComplete() {
    if (!_actionMoving && !_actionMerging && !_actionMoveWithMerging) {
      return true; // can move
    }
    
    return false;
  }
}