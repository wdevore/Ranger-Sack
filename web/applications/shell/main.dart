library shell;

import 'dart:html';
import 'package:ranger/ranger.dart' as Ranger;

// Ranger application access
Ranger.Application _app;

void main() {
_app = new Ranger.Application.fitDesignToWindow(
   window, 
   Ranger.CONFIG.surfaceTag,
   preConfigure,
   1900, 1200
   );

}

void preConfigure() {
}