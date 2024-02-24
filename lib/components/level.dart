import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_tests/components/background_tile.dart';
import 'package:flutter_tests/components/checkpoint.dart';
import 'package:flutter_tests/components/collision_block.dart';
import 'package:flutter_tests/components/fruit.dart';
import 'package:flutter_tests/components/player.dart';
import 'package:flutter_tests/components/saw.dart';
import 'package:flutter_tests/pixel_adventure.dart';
class Level extends World with HasGameRef<pixel_adventure>{
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;
  List<CollisionBlock>collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async{

    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    return super.onLoad();
  }
  

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if(backgroundLayer != null){
      final backgroundColor = 
          backgroundLayer.properties.getValue('BackgroundColor');
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray',
            position: Vector2(0,0)
          );
          add(backgroundTile);
    }
  }
  
  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if(spawnPointsLayer != null){
      for(final spawnPoint in spawnPointsLayer.objects){
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint.name,
              position: Vector2(spawnPoint.x,spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height)
            );
            add(fruit);
            break;
          case 'Saw':
            final bool isVertical =spawnPoint.properties.getValue('isVertical');
            final double offNeg =spawnPoint.properties.getValue('offNeg');
            final double offPos =spawnPoint.properties.getValue('offPos');
            final saw = Saw(isVertical: isVertical,
            offNeg: offNeg,
            offPos: offPos,
              position: Vector2(spawnPoint.x,spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height));
              add(saw);
              break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x,spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height));
              add(checkpoint);
          default:
        }
      }
    }
  }
  
  void _addCollisions() {    
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null){
      for(final collision in collisionsLayer.objects){
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size : Vector2(collision.width, collision.height),
              isPlatform: true
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
          final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size : Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(platform);
          add(platform);
        }
        
      }
    }
    player.collisionBlocks = collisionBlocks;
    }
}