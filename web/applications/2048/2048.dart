library twenty48;

import 'dart:html';
import 'dart:async';

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as UTE;

part 'resources/resources.dart';
part 'resources/widgets/button_widget.dart';

part 'game_manager.dart';

// The splash scene is where resources are loaded for the first level.
part 'scenes/splash/splash_scene.dart';
part 'scenes/splash/splash_layer.dart';

// The scene where the player makes a choice: play or instructions.
part 'scenes/game/entry_scene.dart';
part 'scenes/game/entry_layer.dart';

// The scene where the player read instructions
part 'scenes/game/instructions_scene.dart';
part 'scenes/game/instructions_layer.dart';

// The main game scene where the fun begins.
part 'scenes/game/game_scene.dart';
part 'scenes/game/game_layer.dart';

// Ranger application access
Ranger.Application _app;

void main() {
  _app = new Ranger.Application.fitDesignToWindow(
      window, 
      Ranger.CONFIG.surfaceTag,
      preConfigure,
      800, 480
      );
}

// Optional.
void _shutdown() {
  Ranger.Application.instance.shutdown();
}

void preConfigure() {
  //---------------------------------------------------------------
  // The Incoming scene after the splash screen.
  //---------------------------------------------------------------
  EntryScene entryScene = new EntryScene(2001);

  //---------------------------------------------------------------
  // Create a splash scene with a layer that will be shown prior
  // to transitioning to the main scene.
  //---------------------------------------------------------------
  SplashScene splashScene = new SplashScene.withReplacementScene(entryScene);
  splashScene.pauseFor = 2.0;
  
  // Create BootScene and push it onto the currently empty scene stack. 
  Ranger.BootScene bootScene = new Ranger.BootScene(splashScene);

  // Once the boot scene's onEnter is called it will immediately replace
  // itself with the replacement Splash screen.
  _app.sceneManager.pushScene(bootScene);
  
  // Now complete the pre configure by signaling Ranger.
  _app.gameConfigured();
}
