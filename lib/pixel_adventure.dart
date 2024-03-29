import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
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

  late Level currWorld;

  List<String> levelNames = ['TT-00', 'TT-02', 'TT-03', 'TT-04', 'TT-01', 'TT-05', 'TT-06','TT-07', 'TT-08','TT-09','TT-10'];
  int currentLevelIndex = 5;

  @override
  FutureOr<void> onLoad() async{
    // Load all images into cache
    await images.loadAllImages();

    //debugMode =true;
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
    currWorld.deleteAll();
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
      currWorld = Level(
          player : Player(character: 'Ninja Frog'), 
          levelName: levelNames[currentLevelIndex]
        );

    
    // Camera
    cam = CameraComponent.withFixedResolution(world: currWorld ,width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam,currWorld]);
    
    });
  }
}