bool checkCollision(player, block){
  final hitbox = player.hitbox;
  final playerX = player.position.x + hitbox.offsetX;
  final playerY = player.position.y + hitbox.offsetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;
  
  final blockX = block.position.x;
  final blockY = block.position.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.offsetX * 2) - playerWidth : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight  : playerY;

  if(block.isPlatform){
    return(
    // Bottom of platform
    fixedY < blockY + 5 &&
    // Top of platform
    playerY + playerHeight > blockY &&
    // Left side
    fixedX < blockX + blockWidth &&
    // Right side
    fixedX  + playerWidth > blockX);
  }

  return (
    // Bottom of platform
    fixedY < blockY + blockHeight &&
    // Top of platform
    playerY + playerHeight > blockY &&
    // Left side
    fixedX < blockX + blockWidth &&
    // Right side
    fixedX  + playerWidth > blockX
  );
}