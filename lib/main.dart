import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tests/pixel_adventure.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  pixel_adventure game = pixel_adventure();
  runApp(GameWidget(game: kDebugMode ? pixel_adventure() : game));
}
