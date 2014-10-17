library twenty48;

import 'dart:html';
import 'dart:async';
import 'dart:math' as Math;

import 'package:ranger/ranger.dart' as Ranger;
import 'package:tweenengine/tweenengine.dart' as UTE;
import 'package:vector_math/vector_math.dart';
import 'package:lawndart/lawndart.dart';

part 'resources/resources.dart';

part 'scenes/game/game_manager.dart';

// The splash scene is where resources are loaded for the first level.
part 'scenes/splash/splash_scene.dart';
part 'scenes/splash/splash_layer.dart';

// The main game scene where the fun begins.
part 'scenes/game/game_scene.dart';
part 'scenes/game/game_layer.dart';
part 'scenes/game/slide_panel.dart';

part 'scenes/game/grid/grid.dart';
part 'scenes/game/grid/grid_message.dart';
part 'scenes/game/grid/tile.dart';

part 'scenes/game/widgets/button_widget.dart';
part 'scenes/game/widgets/popup_widget.dart';
part 'scenes/game/widgets/round_rectangle.dart';

/*
 * Tasks:
 * - DONE Arrow buttons (needs recource loading -- or use embedded resource.
 * - DONE load/store high score, current score 
 * - DONE New game and help button
 * - DONE Help
 * - DONE Ability to choose win score 512 to 65536.
 * - DONE show Ranger version on help dialog.
 * - DONE When reset grid overlay fade-in dialog briefly saying "Game Reset!"
 * - DONE Add Win grid overlay.
 * - DONE Add lose overlay: a fade-in over grid appears titled: "Game over!" which
 *   also includes a "Try again" button. Also, show "Powered by Ranger-Dart Engine".
 *
 * - Add animation of Score and Best increase.
 */
// Ranger application access
Ranger.Application _app;

void main() {
  _app = new Ranger.Application.fitDesignToWindow(
      window, 
      Ranger.CONFIG.surfaceTag,
      preConfigure,
      1900, 1200
      );
  
  // Page hide occurs when an Onload occurs
  //window.onPageHide.listen((Event e) {
  //  print("hide");
  //});
}

void preConfigure() {
  //---------------------------------------------------------------
  // The Incoming scene after the splash screen.
  //---------------------------------------------------------------
  GameScene entryScene = new GameScene();
  
  //---------------------------------------------------------------
  // Create a splash scene with a layer that will be shown prior
  // to transitioning to the main scene.
  //---------------------------------------------------------------
  SplashScene splashScene = new SplashScene.withReplacementScene(entryScene);
  splashScene.pauseFor = 0.0;
  
  // Create BootScene and push it onto the currently empty scene stack. 
  Ranger.BootScene bootScene = new Ranger.BootScene(splashScene);

  // Once the boot scene's onEnter is called it will immediately replace
  // itself with the replacement Splash screen.
  _app.sceneManager.pushScene(bootScene);
  
  // Now complete the pre configure by signaling Ranger.
  _app.gameConfigured();
}
