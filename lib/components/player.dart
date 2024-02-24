import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_tests/components/checkpoint.dart';
import 'package:flutter_tests/components/collision_block.dart';
import 'package:flutter_tests/components/custom_hitbox.dart';
import 'package:flutter_tests/components/fruit.dart';
import 'package:flutter_tests/components/saw.dart';
import 'package:flutter_tests/components/utils.dart';
import 'package:flutter_tests/pixel_adventure.dart';
import 'package:flutter/services.dart';


enum PlayerState {
  idle, running, jumping, falling, hit, appearing, disappearing
}


class Player extends SpriteAnimationGroupComponent with HasGameRef<pixel_adventure>, KeyboardHandler, CollisionCallbacks{

  String character;
  Player({position, this.character = 'Ninja Frog'}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearAnimation;
  late final SpriteAnimation disappearAnimation;

  final double stepTime = 0.05;


  // Gravity and Jumps
  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;

  //SpawnPoint
  Vector2 startingPosition = Vector2.zero();
  bool gotHit = false;

    //Checkpoint
  bool reachedCheckpoint = false;

  // Horizontal
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  // Platforms
  List<CollisionBlock> collisionBlocks = [];

  // Hitbox
  custom_hitbox hitbox = custom_hitbox(
    offsetX: 10, 
    offsetY: 4, 
    width: 14,
    height: 28);
  
  double fixedDeltaTime = 1/60;
  double accumulatedTime = 0;
  
  @override
  FutureOr<void> onLoad() {
    // Ran at the beginning of the load
    _loadAllAnimations();

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height)
    ));
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime){
      if(!gotHit && !reachedCheckpoint){
            _updatePlayerState();
            _updatePlayerMovement(fixedDeltaTime);
            _checkHorizontalCollisions();
            _applyGravity(fixedDeltaTime);
            _checkVerticalCollisions();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);    

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart
    if(!reachedCheckpoint){
      if(other is Fruit) other.collidingWithPlayer();

      if(other is Saw) _respawn();

      if(other is Checkpoint) _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    // Idle
    idleAnimation = _loadAnimation(character, 'Idle', 11);

    // Running
    runningAnimation = _loadAnimation(character, 'Run', 12);

    // Jumping
    jumpingAnimation = _loadAnimation(character, 'Jump', 1);
    // Falling
    fallingAnimation = _loadAnimation(character, 'Fall', 1);
    
    // Hit
    hitAnimation = _loadAnimation(character, 'Hit', 7)..loop = false;

    // Appear
    appearAnimation = _specialLoadAnimation('Appearing', 7)..loop = false;
    
    disappearAnimation = _specialLoadAnimation('Desappearing', 7)..loop = false;

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,  
      PlayerState.hit : hitAnimation,
      PlayerState.appearing : appearAnimation,
      PlayerState.disappearing : disappearAnimation,
    };
  // Set current animation  
    current = PlayerState.idle;
  }

  SpriteAnimation _loadAnimation(String character, String action, int amount){
   return SpriteAnimation.fromFrameData(game.images.fromCache('Main Characters/$character/$action (32x32).png'), 
    SpriteAnimationData.sequenced(
      amount: amount, 
      stepTime: stepTime, 
      textureSize: Vector2.all(32)));
  }
  
  SpriteAnimation _specialLoadAnimation(String action, int amount){
   return SpriteAnimation.fromFrameData(game.images.fromCache('Main Characters/Appearing (96x96).png'), 
    SpriteAnimationData.sequenced(
      amount: amount, 
      stepTime: stepTime, 
      textureSize: Vector2.all(96)));
  }
  
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }
    else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }

    if (velocity.x != 0){
      playerState = PlayerState.running;
    }

    if(velocity.y > _gravity) playerState = PlayerState.falling;
    if(velocity.y < 0) playerState = PlayerState.jumping;
    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if(hasJumped && isOnGround) _playerJump(dt);


    // If you can't jump in mid-air
    //if(velocity.y > _gravity) isOnGround = false;

    velocity.x = horizontalMovement * moveSpeed;
    position.x += (velocity.x * dt);
  }
  
  void _checkHorizontalCollisions() {
    for(final block in collisionBlocks){
      // handle collision
      if(!block.isPlatform){
        if(checkCollision(this, block)){
          if(velocity.x > 0){
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
          }
          else if(velocity.x < 0){
            velocity.x = 0;
            position.x = block.x + hitbox.width + hitbox.offsetX + block.width;
          }
        }
      }
    }
  }
   
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }
  
  
  void _checkVerticalCollisions() {
    for(final block in collisionBlocks){
      if(block.isPlatform){
        // handle platforms
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      }
      else{
        if(checkCollision(this,block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }
  
  
  void _playerJump(double dt) {
    if(game.playSounds) FlameAudio.play('jump.wav', volume : game.soundVolume);
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
  
  void _respawn() async{
    if(game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = PlayerState.hit;
    
    await animationTicker?.completed;
    animationTicker?.reset();
    
    scale.x = 1;
    position = startingPosition - Vector2.all(96 - 64);
    current = PlayerState.appearing;  
    
    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
        
    Future.delayed(canMoveDuration, () => gotHit = false);
  }
  
  void _reachedCheckpoint() async{

    if(game.playSounds) FlameAudio.play('disappear.wav', volume: game.soundVolume);
    reachedCheckpoint = true;
    if(scale.x > 0){
      position = position - Vector2.all(32);
    } else if (scale.x < 0){
      position = position + Vector2(32, -32);
    }

    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;

      position = Vector2.all(-640);

            const waitToChangeDuration = Duration (seconds: 3);
      Future.delayed(waitToChangeDuration, () {
        game.loadNextLevel();
      });


  }

}