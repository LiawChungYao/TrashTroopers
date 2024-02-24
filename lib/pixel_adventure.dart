import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_tests/components/jump_button.dart';
import 'package:flutter_tests/components/player.dart';
import 'package:flutter_tests/components/level.dart';

class pixel_adventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection, TapCallbacks{
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;

  Player player = Player(character: 'Ninja Frog');
  
  late JoystickComponent joystick;

  bool showControls = false;
 
  bool playSounds = true;
  double soundVolume = 1.0;

  List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async{
    // Load all images into cache
    await images.loadAllImages();

    _loadLevel();
    
    if(showControls){
      addJoystick();
      add(JumpButton());
    }
    return super.onLoad();
  }
  
  @override
  void update(double dt) {

    if(showControls){
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 100,
      knob : SpriteComponent(sprite: Sprite(images.fromCache('HUD/Knob.png'))),
      background: SpriteComponent(sprite: Sprite(images.fromCache('HUD/Joystick.png'))),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    
    add(joystick);
  }
  
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }

  }
  
  void loadNextLevel(){
    if(currentLevelIndex < levelNames.length -1){
      currentLevelIndex++;
    } else {
      // No more levels
      currentLevelIndex = 0;
    }
    _loadLevel();
  }

  void _loadLevel() {
    Future.delayed(const Duration(milliseconds: 350 ,), (){
      Level world = Level(
          player : player, 
          levelName: levelNames[currentLevelIndex]
        );

    
    // Camera
    cam = CameraComponent.withFixedResolution(world: world ,width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam,world]);
    
    });
  }
}