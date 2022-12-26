import 'dart:collection';

import 'package:flutter/cupertino.dart';

abstract class Card {
  final int pk;

  Card({required this.pk});
}

class TextCard extends Card {
  final String text;

  TextCard({
    required int pk,
    required this.text,
  }) : super(pk: pk);

  TextCard copyWith({String? text}) => TextCard(
        pk: pk,
        text: text ?? this.text,
      );
}

enum CardRelativePosition { above, below }

class ImageCard extends Card {
  final ImageProvider image;
  final CardRelativePosition textPosition;
  final String text;

  ImageCard({
    required pk,
    required this.image,
    required this.textPosition,
    required this.text,
  }) : super(pk: pk);
}

class Wish {
  int pk;

  String title;
  List<Card> cards;

  /// Permanent name
  String checkedBy;

  bool get isChecked => checkedBy.isNotEmpty;

  Wish({
    required this.pk,
    required this.title,
    this.cards = const [],
    this.checkedBy = '',
  });

  Wish copyWith({
    String? title,
    String? checkedBy,
    List<Card>? cards,
  }) =>
      Wish(
        pk: pk,
        title: title ?? this.title,
        checkedBy: checkedBy ?? this.checkedBy,
        cards: cards ?? this.cards,
      );
}

class User {
  String permanentName;
  String displayName;
  String discoveryName;
  List<Wish> wishes;

  User({
    required this.permanentName,
    required this.wishes,
    required this.discoveryName,
    required this.displayName,
  });
}

class UsersSet {
  final Map<String, User> _users = <String, User>{};

  void add(User user) {
    if (_users.containsKey(user.permanentName)) {
      throw ArgumentError('Cannot have two users with the same permanent name ("${user.permanentName}") in a single `UserSer` instance.');
    }
    _users[user.permanentName] = user;
  }

  void override(User user) {
    _users[user.permanentName] = user;
  }

  void remove(String permanentName) {
    _users.remove(permanentName);
  }

  User? operator [](String permanentName) {
    return _users[permanentName];
  }

  Iterable<User> toIterable() {
    return _users.values;
  }

  Map<String, User> toMap() {
    return Map.unmodifiable(_users);
  }
}
