import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_tests/components/custom_hitbox.dart';
import 'package:flutter_tests/pixel_adventure.dart';

class Dumpster extends SpriteAnimationComponent with HasGameRef<pixel_adventure>, CollisionCallbacks{
  Dumpster({position, size}) : super(position: position, size: size);

  late int numberToWin;
  late int currNum = 0;
  final double stepTime = 0.05;

  bool collected = false;
  final hitbox = custom_hitbox(
  offsetX: 10, 
  offsetY: 10, 
  width: 12, 
  height: 12);

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    add(RectangleHitbox(
      position : Vector2(hitbox.offsetX, hitbox.offsetY),
      size : Vector2(hitbox.width, hitbox.height),
      collisionType: CollisionType.passive,
      ));

    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Fruits/Dumpster.png'), SpriteAnimationData.sequenced(
        amount: 17, 
        stepTime: stepTime, 
        textureSize: Vector2.all(32)));

    return super.onLoad();
  }

  bool collidingWithPlayer(int curr){
    currNum += curr;
    if (numberToWin <= currNum){
      return true;
    }
    return false;
  }

  void assignNumberToWin(int num){
    numberToWin = num;
  }

}