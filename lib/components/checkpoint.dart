import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_tests/components/player.dart';
import 'package:flutter_tests/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<pixel_adventure>, CollisionCallbacks     {
  Checkpoint({position,size}) : super(position:position, size:size);
  @override
  FutureOr<void> onLoad() {
    //debugMode = true; 
    add(RectangleHitbox(position: Vector2(18, 56), size: Vector2(12, 8), collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
    SpriteAnimationData.sequenced(
      amount: 1, 
      stepTime: 1, 
      textureSize: Vector2.all(64))
    );
    // TODO: implement onLoad
    return super.onLoad();
  }

  
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart
    
    if(other is Player) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async{
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
    SpriteAnimationData.sequenced(
      amount: 26, 
      stepTime: 0.05, 
      textureSize: Vector2.all(64),
      loop: false
      )
    );

    await animationTicker?.completed;
    animation = SpriteAnimation.fromFrameData(game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'), 
      SpriteAnimationData.sequenced(
        amount: 10, 
        stepTime: 0.05, 
        textureSize: Vector2.all(64))
    );
  }
}