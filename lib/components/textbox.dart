import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flutter_tests/pixel_adventure.dart';

final style = TextStyle(color : Color.fromARGB(255, 0, 0, 0));

final regular = TextPaint(style: style);

class TextBox extends PositionComponent with HasGameRef<pixel_adventure>{
  String texts;
  TextBox({this.texts = 'No String',position, size}) : super(position: position, size: size);

  
  TextComponent content = TextComponent();

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    content..text = texts..textRenderer = regular;
    content.position = Vector2(5, -12);
    add(content);
    return super.onLoad();
  }
}
