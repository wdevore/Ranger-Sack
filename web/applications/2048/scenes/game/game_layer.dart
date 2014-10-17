part of twenty48;

/**
 */
class GameLayer extends Ranger.BackgroundLayer {
  Grid _grid = new Grid();

  ButtonWidget _leftArrow;
  ButtonWidget _rightArrow;
  ButtonWidget _upArrow;
  ButtonWidget _downArrow;

  ButtonWidget _config;
  ButtonWidget _newGame;
  ButtonWidget _resetButton;

  ButtonWidget _max512;
  ButtonWidget _max1024;
  ButtonWidget _max2048;
  ButtonWidget _max4096;
  ButtonWidget _max8192;
  ButtonWidget _max16384;
  ButtonWidget _max32768;
  ButtonWidget _max65536;

  ButtonWidget _help;
  
  bool _configured = false;
  
  SlidePanel _instructionPanel;
  SlidePanel _configPanel;
  SlidePanel _resetPanel;
  SlidePanel _winPanel;
  SlidePanel _losePanel;
  
  Math.Random _randGen = new Math.Random();
  
  GameLayer();
 
  factory GameLayer.withColor(Ranger.Color4<int> backgroundColor, [bool centered = true, int width, int height]) {
    GameLayer layer = new GameLayer();
    layer.centered = centered;
    layer.init(width, height);
    layer.transparentBackground = false;
    layer.color = backgroundColor;
    layer.showOriginAxis = false;
    return layer;
  }

  @override
  bool init([int width, int height]) {
    if (super.init(width, height)) {
      UTE.Tween.registerAccessor(Ranger.TextNode, Ranger.Application.instance.animations);
      
      _configure();
    }

    return true;
  }
  
  void _configure() {
    Ranger.Size size = contentSize;
    double hWidth = size.width / 2.0;
    double hHeight = size.height / 2.0;
    
    _addText(hWidth, hHeight);
    
    GameManager gm = GameManager.instance;
    _grid.build(this);
    gm.grid = _grid;
    
    _addScoreArea(hWidth, hHeight);
    
    _addHighScoreArea(hWidth, hHeight);
    
    _addInstructionsButton();
    
    _registerWithEventBus();
    
    _addInstructions();
    _addConfig();
    _addResetPopUp();
    _addWinPopUp();
    _addLosePopUp();
  }

  void _registerWithEventBus() {
    Ranger.Application.instance.eventBus.on(GridMessage).listen(
    (GridMessage md) {
      _processGridMessage(md);
    });

    Ranger.Application.instance.eventBus.on(ButtonWidget).listen(
    (ButtonWidget md) {
      _processButtonMessage(md);
    });

    Ranger.Application.instance.eventBus.on(SlidePanel).listen(
    (SlidePanel md) {
      _processPanelMessage(md);
    });
  }

  void _processPanelMessage(SlidePanel msg) {
    if (msg.id == "Instructions") {
      switch (msg.action) {
        case SlidePanel.ACTION_CLICKED:
          _instructionPanel.toggle();
          break;
        case SlidePanel.ACTION_HIDDEN:
          break;
      }
    }
    else if (msg.id == "Config") {
      switch (msg.action) {
        case SlidePanel.ACTION_CLICKED:
          _configPanel.toggle();
          break;
        case SlidePanel.ACTION_HIDDEN:
          GameManager.instance.save();
          break;
      }
    }
    else if (msg.id == "Reset PopUp") {
      switch (msg.action) {
        case SlidePanel.ACTION_CLICKED:
          break;
        case SlidePanel.ACTION_REVEALED:
          _reset();
          break;
        case SlidePanel.ACTION_HIDDEN:
          break;
      }
    }
    else if (msg.id == "Win PopUp") {
      switch (msg.action) {
        case SlidePanel.ACTION_CLICKED:
          _winPanel.fadeOut();
          break;
        case SlidePanel.ACTION_HIDDEN:
          _aNewGame();
          break;
      }
    }
    else if (msg.id == "Lose PopUp") {
      switch (msg.action) {
        case SlidePanel.ACTION_CLICKED:
          _losePanel.fadeOut();
          break;
        case SlidePanel.ACTION_HIDDEN:
          _aNewGame();
          break;
      }
    }
  }
  
  void _processButtonMessage(ButtonWidget msg) {
    if (!_canProcessAction()) {
      return;
    }

    if (msg.id == "left") {
      _moveLeft();
    }
    else if (msg.id == "right") {
      _moveRight();
    }
    else if (msg.id == "up") {
      _moveUp();
    }
    else if (msg.id == "down") {
      _moveDown();
    }
    else if (msg.id == "New Game") {
      _aNewGame();
    }
    else if (msg.id == "Instructions") {
      _instructionPanel.toggle();
    }
    else if (msg.id == "Config") {
      _max512.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max1024.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max2048.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max4096.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max8192.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max16384.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max32768.backgroundColor = Ranger.color4IFromHex("#41273b");
      _max65536.backgroundColor = Ranger.color4IFromHex("#41273b");
      
      ButtonWidget _max;
      switch(GameManager.instance.maxTile) {
        case 512: _max = _max512; break;
        case 1024: _max = _max1024; break;
        case 2048: _max = _max2048; break;
        case 4096: _max = _max4096; break;
        case 8192: _max = _max8192; break;
        case 16384: _max = _max16384; break;
        case 32768: _max = _max32768; break;
        case 65536: _max = _max65536; break;
        default: _max = _max2048; break;
      }
      _max.backgroundColor = Ranger.color4IFromHex("#279989");

      _configPanel.toggle();
    }
    else if (msg.id == "Reset") {
      _resetPanel.toggleFade();
    }
    else if (msg.id == "512") {
      GameManager.instance.maxTile = 512;
    }
    else if (msg.id == "1024") {
      GameManager.instance.maxTile = 1024;
    }
    else if (msg.id == "2048") {
      GameManager.instance.maxTile = 2048;
    }
    else if (msg.id == "4096") {
      GameManager.instance.maxTile = 4096;
    }
    else if (msg.id == "8192") {
      GameManager.instance.maxTile = 8192;
    }
    else if (msg.id == "16384") {
      GameManager.instance.maxTile = 16384;
    }
    else if (msg.id == "32768") {
      GameManager.instance.maxTile = 32768;
    }
    else if (msg.id == "65536") {
      GameManager.instance.maxTile = 65536;
    }
  }
  
  void _processGridMessage(GridMessage msg) {
    GameManager gm = GameManager.instance;
    
    if (msg.action == GridMessage.ACTION_WON) {
      // Pop up win dialog
      _winPanel.fadeIn();
    }
    else if (msg.action == GridMessage.ACTION_LOST) {
      _losePanel.fadeIn();
    }
    else if (msg.action == GridMessage.ACTION_SCORE_CHANGED) {
      int currentScore = gm.score; 
      gm.score += msg.mergedValue;
      print("currentScore: $currentScore, score: ${gm.score}, merge: ${msg.mergedValue}");
      
      if (gm.score > gm.best) {
        gm.best = gm.score;
      }
      
      // Animate Plus score increases.
      // The animation is both Translate and Fadeout.
      Ranger.TextNode scoreInc = new Ranger.TextNode.initWith(Ranger.Color4IBlack)
          ..text = "+${msg.mergedValue}"
          ..font = "normal 900 10px Verdana"
          ..setPosition(-110.0, 0.0)
          ..uniformScale = 5.0;
      addChild(scoreInc, 103);
      
      _animateScoreInc(scoreInc); 
    }
  }

  @override
  void onEnter() {
    enableKeyboard = true;
    enableMouse = true;
    
    super.onEnter();
    
    GameManager gm = GameManager.instance;
    gm.scoreTile.value = 0;
    gm.bestTile.value = 0;
    
    if (!_configured) {
      _addArrowButtons();
      _addNewGameButton();
      _addInstructionsButton();
      _addConfigButton();
      _configured = true;
    }
  }

  @override
  bool onMouseDown(MouseEvent event) {
    _leftArrow.isOn(event.offset.x, event.offset.y);
    _rightArrow.isOn(event.offset.x, event.offset.y);
    _upArrow.isOn(event.offset.x, event.offset.y);
    _downArrow.isOn(event.offset.x, event.offset.y);
    _newGame.isOn(event.offset.x, event.offset.y);
    
    _help.isOn(event.offset.x, event.offset.y);
    if (_instructionPanel.active) {
      _instructionPanel.isOn(event.offset.x, event.offset.y);
    }

    _config.isOn(event.offset.x, event.offset.y);
    if (_configPanel.active) {
      _configPanel.isOn(event.offset.x, event.offset.y);
      _resetButton.isOn(event.offset.x, event.offset.y);

      _max512.isOn(event.offset.x, event.offset.y);
      _max1024.isOn(event.offset.x, event.offset.y);
      _max2048.isOn(event.offset.x, event.offset.y);
      _max4096.isOn(event.offset.x, event.offset.y);
      _max8192.isOn(event.offset.x, event.offset.y);
      _max16384.isOn(event.offset.x, event.offset.y);
      _max32768.isOn(event.offset.x, event.offset.y);
      _max65536.isOn(event.offset.x, event.offset.y);
    }

    if (_winPanel.active)
      _winPanel.isOn(event.offset.x, event.offset.y);
    if (_losePanel.active)
      _losePanel.isOn(event.offset.x, event.offset.y);

    return true;
  }

  @override
  void onEnterTransitionDidFinish() {
    super.onEnterTransitionDidFinishNode();
    _aNewGame();
    
    GameManager gm = GameManager.instance;
    gm.scoreTile.value = 0;
    gm.bestTile.value = gm.best;
  }

  @override
  bool onKeyDown(KeyboardEvent event) {
    //print("key onKeyDown ${event.keyCode}");

    if (!_canProcessAction()) {
      event.preventDefault();
      return false;
    }
    
    switch (event.keyCode) {
      case 49: //1
        _grid.spawnDebug();
        return true;
      case 50: //2
        _grid.spawnStartTiles();
        return true;
      case 51: //3
        _instructionPanel.toggle();
        return true;
      case 52: //4
        GameManager.instance.maxTile = 8;
        return true;
      case 87: //w = up
      case 38:
        _moveUp();
        event.preventDefault();
        return true;
      case 65: //a = left
      case 37:
        _moveLeft();
        event.preventDefault();
        return true;
      case 83: //s = down
      case 40:
        _moveDown();
        event.preventDefault();
        return true;
      case 68: //d = right
      case 39:
        _moveRight();
        event.preventDefault();
        return true;
    }
    
    return false;
  }

  bool _canProcessAction() {
    if (!_grid.actionsComplete()) {
      return false;
    }
    
    if (_instructionPanel.active || _configPanel.active)
      return false;
    
    return true;
  }
  
  void _moveLeft() {
    _grid.move(-1, 0);
  }
  
  void _moveRight() {
    _grid.move(1, 0);
  }
  
  void _moveUp() {
    _grid.move(0, 1);
  }
  
  void _moveDown() {
    _grid.move(0, -1);
  }
  
  void _aNewGame() {
    GameManager.instance.resetScore();
    _restart();
  }
  
  void _reset() {
    GameManager.instance.reset();
    _restart();
  }
  
  void _restart() {
    // TODO animate tiles off the grid. have them drop off
    _grid.clear();
    // reset score
    // generate two new tiles.
    _grid.spawnStartTiles();
  }
  
  void _addText(double hw, double hh) {
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#686e9f"))
        ..text = "2048"
        ..font = "normal 900 10px Verdana"
        ..shadows = true
        ..setPosition(-670.0, hh - 160.0)
        ..uniformScale = 15.0;
    addChild(line1, 10, 702);
  }

  void _addInstructions() {
    double width = 900.0;
    double height = 900.0;
    
    _instructionPanel = new SlidePanel.basic(
        this,
        Ranger.color4IFromHex("#395542ee"), 
        width, height, 15.0);
    _instructionPanel.id = "Instructions";
    _instructionPanel.dockPosition = _grid.position;
    
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Join the numbers until you get Max tile!"
        ..font = "10px Verdana"
        ..setPosition(-400.0, 375.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line1);

    Ranger.TextNode line2 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Use either "
        ..font = "10px Verdana"
        ..setPosition(-400.0, 300.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line2);

    Ranger.TextNode line2b = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "W,A,S,D"
        ..font = "10px Verdana"
        ..setPosition(-195.0, 300.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line2b);

    Ranger.TextNode line2c = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "keys or arrows keys"
        ..font = "10px Verdana"
        ..setPosition(-20.0, 300.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line2c);

    
    Ranger.TextNode line3 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "to move tiles. When two tiles with the same"
        ..font = "10px Verdana"
        ..setPosition(-400.0, 250.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line3);

    Ranger.TextNode line4 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "number touch, they "
        ..font = "10px Verdana"
        ..setPosition(-400.0, 200.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line4);

    Ranger.TextNode line4a = new Ranger.TextNode.initWith(Ranger.Color4IYellow)
        ..text = "merge into one!"
        ..font = "10px Verdana"
        ..setPosition(-10.0, 200.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line4a);
    
    
    Ranger.TextNode line5 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Click ["
        ..font = "10px Verdana"
        ..setPosition(-400.0, 100.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line5);

    Ranger.TextNode line5a = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "Config"
        ..font = "10px Verdana"
        ..setPosition(-280.0, 100.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line5a);

    Ranger.TextNode line5b = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "] to set Max tile and"
        ..font = "10px Verdana"
        ..setPosition(-160.0, 100.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line5b);

    Ranger.TextNode line5c = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#ff808b"))
        ..text = "Reset."
        ..font = "10px Verdana"
        ..setPosition(235.0, 100.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line5c);

    Ranger.TextNode line5d = new Ranger.TextNode.initWith(Ranger.color4IFromHex("#ff808b"))
        ..text = "Warning: Reset clears everything!"
        ..font = "10px Verdana"
        ..setPosition(-400.0, 2.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line5d);

    Ranger.TextNode line6 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Click panel to dismiss"
        ..font = "10px Verdana"
        ..setPosition(-220.0, -325.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line6);

    Ranger.TextNode line7 = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue)
        ..text = "Powered by Ranger-Dart Engine."
        ..font = "10px Verdana"
        ..setPosition(-320.0, -395.0)
        ..uniformScale = 3.75;
    _instructionPanel.addNode(line7);
  }
  
  void _addInstructionsButton() {
    _help = new ButtonWidget.basic(Ranger.color4IFromHex("#d4b59e"), 80.0, 20.0, 5.0);
    _help..bindTo = this
        ..id = "Instructions"
        ..caption = "Instructions"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.color4IFromHex("#2c5234")
        ..setCaptionOffset(-35.0, -3.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(380.0, 20.0);
  }
  
  void _addScoreArea(double hw, double hh) {
    double px = 320.0;
    double py = hh - 140.0;
    
    GameManager gm = GameManager.instance;
    
    gm.scoreTile = new Tile.initWith(Ranger.color4IFromHex("#b7a99a"));
    addChild(gm.scoreTile, 10, 1001);
    gm.scoreTile.addNumber(Ranger.Color4IWhite);
    
    gm.scoreTile.cornerRadius = 0.07;
    gm.scoreTile.setPosition(px, py - 80.0);
    gm.scoreTile.uniformScale = Grid.TILE_SIZE;
    
    Ranger.TextNode line = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Score"
        ..font = "normal 500 10px Verdana"
        ..setPosition(px - 60.0, py + 40.0)
        ..uniformScale = 4.0;
    addChild(line, 10, 702);
  }
  
  void _addHighScoreArea(double hw, double hh) {
    double px = 620.0;
    double py = hh - 140.0;
    GameManager gm = GameManager.instance;
    
    gm.bestTile = new Tile.initWith(Ranger.color4IFromHex("#b7a99a"));
    addChild(gm.bestTile, 10, 1001);
    gm.bestTile.addNumber(Ranger.Color4IWhite);
    
    gm.bestTile.cornerRadius = 0.07;
    gm.bestTile.setPosition(px, py - 80.0);
    gm.bestTile.uniformScale = Grid.TILE_SIZE;
    
    Ranger.TextNode line = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Best"
        ..font = "normal 500 10px Verdana"
        ..setPosition(px - 50.0, py + 40.0)
        ..uniformScale = 4.0;
    addChild(line, 10, 702);
  }

  void _addConfig() {
    double width = 900.0;
    double height = 900.0;
    
    _configPanel = new SlidePanel.basic(
        this,
        Ranger.color4IFromHex("#633231ee"), 
        width, height, 15.0);
    _configPanel.id = "Config";
    _configPanel.dockPosition = _grid.position;
    
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Click Number to set Max tile."
        ..font = "10px Verdana"
        ..setPosition(-260.0, 375.0)
        ..uniformScale = 3.75;
    _configPanel.addNode(line1);
    
    Ranger.TextNode line6 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Click panel to dismiss"
        ..font = "10px Verdana"
        ..setPosition(-220.0, -375.0)
        ..uniformScale = 3.75;
    _configPanel.addNode(line6);

    _resetButton = new ButtonWidget.basic(Ranger.Color4IWhite, 45.0, 20.0, 5.0);
    _resetButton..id = "Reset"
        ..caption = "Reset"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IRed
        ..setCaptionOffset(-16.0, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(-0.0, -190.0);
    _configPanel.addButtonWidget(_resetButton);

    _max512 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 27.0, 20.0, 3.0);
    _max512..id = "512"
        ..caption = "512"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-11.0, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(-350.0, 280.0);
    _configPanel.addButtonWidget(_max512);
    
    _max1024 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 33.0, 20.0, 3.0);
    _max1024..id = "1024"
        ..caption = "1024"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-14.0, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(-140.0, 280.0);
    _configPanel.addButtonWidget(_max1024);
    
    _max2048 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 33.0, 20.0, 3.0);
    _max2048..id = "2048"
        ..caption = "2048"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-14.0, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(95.0, 280.0);
    _configPanel.addButtonWidget(_max2048);
    
    _max4096 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 33.0, 20.0, 3.0);
    _max4096..id = "4096"
        ..caption = "4096"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-14.0, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(320.0, 280.0);
    _configPanel.addButtonWidget(_max4096);

    _max8192 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 33.0, 20.0, 3.0);
    _max8192..id = "8192"
        ..caption = "8192"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-14.0, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(-350.0, 150.0);
    _configPanel.addButtonWidget(_max8192);
    
    _max16384 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 40.0, 20.0, 3.0);
    _max16384..id = "16384"
        ..caption = "16384"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-17.5, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(-140.0, 150.0);
    _configPanel.addButtonWidget(_max16384);
    
    _max32768 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 40.0, 20.0, 3.0);
    _max32768..id = "32768"
        ..caption = "32768"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-17.5, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(100.0, 150.0);
    _configPanel.addButtonWidget(_max32768);
    
    _max65536 = new ButtonWidget.basic(Ranger.color4IFromHex("#41273b"), 40.0, 20.0, 3.0);
    _max65536..id = "65536"
        ..caption = "65536"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.Color4IOrange
        ..setCaptionOffset(-17.5, -4.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(320.0, 150.0);
    _configPanel.addButtonWidget(_max65536);
  }
  
  void _addConfigButton() {
    _config = new ButtonWidget.basic(Ranger.color4IFromHex("#d4b59e"), 45.0, 20.0, 5.0);
    _config..bindTo = this
        ..id = "Config"
        ..caption = "Config"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.color4IFromHex("#535486")
        ..setCaptionOffset(-18.0, -3.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(750.0, 90.0);
  }
  
  void _addNewGameButton() {
    _newGame = new ButtonWidget.basic(Ranger.color4IFromHex("#d4b59e"), 80.0, 20.0, 5.0);
    _newGame..bindTo = this
        ..id = "New Game"
        ..caption = "New Game"
        ..font = "normal 900 10px Verdana"
        ..captionColor = Ranger.color4IFromHex("#5c4738")
        ..setCaptionOffset(-30.0, -3.0)
        ..node.uniformScale = 5.0
        ..node.setPosition(380.0, 150.0);
  }
  
  void _addArrowButtons() {
    double x = 470.0;
    double y = -210.0;
    
    _leftArrow = new ButtonWidget.withElement(GameManager.instance.resources.arrow_left);
    _leftArrow..bindTo = this
        ..id = "left"
        ..node.uniformScale = 5.0
        ..node.setPosition(x - 140.0, y - 100.0);

    _rightArrow = new ButtonWidget.withElement(GameManager.instance.resources.arrow_left);
    _rightArrow..bindTo = this
        ..id = "right"
        ..node.rotationByDegrees = 180.0
        ..node.uniformScale = 5.0
        ..node.setPosition(x + 140.0, y - 100.0);

    _upArrow = new ButtonWidget.withElement(GameManager.instance.resources.arrow_up);
    _upArrow..bindTo = this
        ..id = "up"
        ..node.uniformScale = 5.0
        ..node.setPosition(x, y + 30.0);

    _downArrow = new ButtonWidget.withElement(GameManager.instance.resources.arrow_up);
    _downArrow..bindTo = this
        ..id = "down"
        ..node.rotationByDegrees = 180.0
        ..node.uniformScale = 5.0
        ..node.setPosition(x, y - 230.0);
  }

  void _addResetPopUp() {
    double width = 900.0;
    double height = 900.0;
    
    _resetPanel = new SlidePanel.basic(
        this,
        Ranger.color4IFromHex("#487a7b"), 
        width, height, 15.0, 300);
    _resetPanel.id = "Reset PopUp";
    _resetPanel.dockPosition = _grid.position;
    
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Game has been"
        ..font = "10px Verdana"
        ..setPosition(-180.0, 190.0)
        ..uniformScale = 3.75;
    _resetPanel.addNode(line1);
    Ranger.TextNode line2 = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "Reset!"
        ..font = "normal 900 10px Verdana"
        ..setPosition(-360.0, -100.0)
        ..uniformScale = 20.0;
    _resetPanel.addNode(line2);
  }

  void _addWinPopUp() {
    double width = 900.0;
    double height = 900.0;
    
    _winPanel = new SlidePanel.basic(
        this,
        Ranger.color4IFromHex("#e1b87f"), 
        width, height, 15.0, 300);
    _winPanel.id = "Win PopUp";
    _winPanel.dockPosition = _grid.position;
    _winPanel.fadeBackgroundOnly = true;
    _winPanel.maxFadeInAlpha = 128 + 32;
    
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IDarkBlue)
        ..text = "You Won!"
        ..font = "normal 900 10px Verdana"
        ..shadows = true
        ..setPosition(-400.0, 80.0)
        ..uniformScale = 15.0;
    _winPanel.addNode(line1);
    Ranger.TextNode line2 = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "Sweeeeet!"
        ..font = "normal 900 10px Verdana"
        ..shadows = true
        ..setPosition(-390.0, -130.0)
        ..uniformScale = 13.0;
    _winPanel.addNode(line2);
    
    Ranger.TextNode line6 = new Ranger.TextNode.initWith(Ranger.Color4IDarkBlue)
        ..text = "Click panel to dismiss"
        ..font = "10px Verdana"
        ..setPosition(-220.0, -325.0)
        ..uniformScale = 3.75;
    _winPanel.addNode(line6);

  }
  
  void _addLosePopUp() {
    double width = 900.0;
    double height = 900.0;
    
    _losePanel = new SlidePanel.basic(
        this,
        Ranger.color4IFromHex("#4b4f54"), 
        width, height, 15.0, 300);
    _losePanel.id = "Lose PopUp";
    _losePanel.dockPosition = _grid.position;
    _losePanel.fadeBackgroundOnly = true;
    _losePanel.maxFadeInAlpha = 128 + 32;
    
    Ranger.TextNode line1 = new Ranger.TextNode.initWith(Ranger.Color4IDartBlue)
        ..text = "You Lose!"
        ..font = "normal 900 10px Verdana"
        ..shadows = true
        ..setPosition(-400.0, 80.0)
        ..uniformScale = 15.0;
    _losePanel.addNode(line1);
    Ranger.TextNode line2 = new Ranger.TextNode.initWith(Ranger.Color4IOrange)
        ..text = "Arrrrgh!"
        ..font = "normal 900 10px Verdana"
        ..shadows = true
        ..setPosition(-310.0, -130.0)
        ..uniformScale = 13.0;
    _losePanel.addNode(line2);
    
    Ranger.TextNode line6 = new Ranger.TextNode.initWith(Ranger.Color4IWhite)
        ..text = "Click panel to dismiss"
        ..font = "10px Verdana"
        ..setPosition(-220.0, -325.0)
        ..uniformScale = 3.75;
    _losePanel.addNode(line6);
  }

  void _animateScoreInc(Ranger.TextNode scoreInc) {
    Ranger.Application app = Ranger.Application.instance;
    GameManager gm = GameManager.instance;
    
    // Set position of text. To that we need to map the tile's position
    // into Game-space.
    scoreInc.position = gm.scoreTile.position;
    double dx = Math.sin(_randGen.nextDouble() * 6.28);
    double dy = Math.cos(_randGen.nextDouble() * 6.28);
    
    UTE.BaseTween moveBy = app.animations.moveBy(scoreInc, 
        2.0, dx * 50.0, dy * 50.0, 
        UTE.Cubic.OUT, Ranger.TweenAnimation.TRANSLATE_XY,
        null, false);

    UTE.BaseTween fadeOut = app.animations.fadeOut(scoreInc, 
        2.0, 
        UTE.Linear.INOUT,
        null, false);

    UTE.Timeline par = new UTE.Timeline.parallel()
      ..push(moveBy)
      ..push(fadeOut)
      ..userData = scoreInc
      ..callback = _animateScoreIncComplete
      ..callbackTriggers = UTE.TweenCallback.COMPLETE;
    
    app.animations.add(par);
  }
  
  void _animateScoreIncComplete(int type, UTE.BaseTween source) {
    Ranger.TextNode node = source.userData as Ranger.TextNode;
    removeChild(node, true);
  }
  
}
