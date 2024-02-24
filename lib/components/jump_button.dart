import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_tests/pixel_adventure.dart';

class JumpButton extends SpriteComponent with HasGameRef<pixel_adventure>, TapCallbacks{
  JumpButton();


  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {

    sprite = Sprite( game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize, 
      game.size.y - margin - buttonSize,
      );
      
    // TODO: implement onLoad
    
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    // TODO: implement onTapDown
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    // TODO: implement onTapUp
    super.onTapUp(event);
  }

}