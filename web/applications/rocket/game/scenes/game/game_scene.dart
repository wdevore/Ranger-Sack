part of ranger_rocket;

class GameScene extends Ranger.AnchoredScene {
  Ranger.Scene _replacementScene;
  Ranger.GroupNode _group;

  ControlsDialog _controlsPanel;

  GameScene([int tag = 2001]) {
    this.tag = tag;
  }

  GameScene.withPrimary(Ranger.Node primary, [Ranger.Scene replacementScene, Function completeVisit]) {
    initWithPrimary(primary);
    _replacementScene = replacementScene;
  }
  
  @override
  bool init() {
    if (super.init()) {
      GameManager gm = GameManager.instance;
      gm.init();
      
      gm.gameScene = this;
      
      _group = new Ranger.GroupNode.basic();
      _group.tag = 2011;
      initWithPrimary(_group);
    
      _controlsPanel = new ControlsDialog.withHideCallback(_panelAction);

      Ranger.Application app = Ranger.Application.instance;
      // The GameScene needs to listen for events from the GameLayer
      // I do this because I don't want a tight coupling between Layer
      // and Scene.
      app.eventBus.on(MessageData).listen(
      (MessageData md) {
        switch(md.actionData) {
          case MessageData.SHOW_PANEL:
            if (!_controlsPanel.isShowing)
              _controlsPanel.show();
            break;
        }
      });
      
      //---------------------------------------------------------------
      // Main game layer where the action is. ddddaa = olive green
      //---------------------------------------------------------------
      addLayer(gm.gameLayer, 0, 2010);
  
      //---------------------------------------------------------------
      // A layer that overlays on top of the game layer. For example, FPS.
      //---------------------------------------------------------------
      addLayer(gm.hudLayer, 0, 2012);
    }    
    return true;
  }

  _panelAction(String title) {
    GameManager gm = GameManager.instance;

    switch(title) {
      case "Help":
        gm.hudLayer.toggleHelp();
        break;
      case "HUD on/off":
        gm.hudLayer.visible = !gm.hudLayer.visible;
        break;
      case "Origin on/off":
        gm.gameLayer.showOriginAxis = !gm.gameLayer.showOriginAxis;
        if (gm.gameLayer.showOriginAxis)
          gm.hudLayer.textMessage = "Origin axis visual turned on";
        else
          gm.hudLayer.textMessage = "Origin axis visual turned off";
        gm.hudLayer.animateMessage();
        break;
      case "Activate Triangle ship":
        gm.gameLayer.activeShip = GameLayer.TRIANGLE_SHIP;
        gm.hudLayer.autoScrollEnabled = true;
        gm.hudLayer.textMessage = "Triangle ship activated, auto scroll activated.";
        gm.hudLayer.animateMessage();
        break;
      case "Activate DualCell ship":
        gm.gameLayer.activeShip = GameLayer.DUALCELL_SHIP;
        gm.hudLayer.textMessage = "DualCell ship activated";
        gm.hudLayer.animateMessage();
        break;
      case "Activate Spike ship":
        gm.gameLayer.activeShip = GameLayer.SPIKE_SHIP;
        if (gm.spikeShip.visible) {
          // Make sure zoom-center is centered on spike ship as well.
          gm.hudLayer.autoScrollEnabled = false;
          gm.hudLayer.textMessage = "Spike ship activated, Auto Scroll deactivated";
        }
        else {
          gm.gameLayer.activeShip = GameLayer.TRIANGLE_SHIP;
          gm.hudLayer.textMessage = "Spike ship deactivated, Triangle ship activated";
        }
        gm.hudLayer.animateMessage();
        break;
      case "Toggle Scroll zone visuals":
        gm.hudLayer.toggleScrollZoneVisibility();
        break;
      case "Toggle Scroll damping":
        gm.hudLayer.dampingEnabled = !gm.hudLayer.dampingEnabled;
        break;
      case "Toggle Auto Scroll":
        gm.hudLayer.autoScrollEnabled = !gm.hudLayer.autoScrollEnabled;
        if (gm.hudLayer.autoScrollEnabled)
          gm.hudLayer.textMessage = "Auto Scroll enabled for Triangle ship";
        else
          gm.hudLayer.textMessage = "Auto Scroll disabled for Triangle ship";
        gm.hudLayer.animateMessage();
        break;
      case "Toggle Object zone visuals":
        bool visible = gm.gameLayer.toggleObjectZoneVisibility();
        if (visible)
          gm.hudLayer.textMessage = "Object zone visuals turned on";
        else
          gm.hudLayer.textMessage = "Object zone visuals turned off";
        gm.hudLayer.animateMessage();
        break;
    }
    
  }

  @override
  void onEnter() {
    super.onEnter();

    // We set the position because a transition may have changed it during
    // an animation.
    setPosition(0.0, 0.0);
  }

}
