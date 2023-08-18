part of '../fl_channel.dart';

class FlBasicMessage {
  factory FlBasicMessage() => _singleton ??= FlBasicMessage._();

  FlBasicMessage._();

  static FlBasicMessage? _singleton;
}
