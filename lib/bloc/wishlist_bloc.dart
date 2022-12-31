import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models.dart';
import '../utils/collections.dart';

abstract class WishlistState {
  const WishlistState();
}

abstract class WithUserPk {
  String get userPk;
}

abstract class WithWishPk {
  int get wishPk;
}

abstract class WithCardPk {
  int get cardPk;
}

// mixin WithUserPkMixin implements WithUserPk {
//   @override
//   late String userPk;
// }

// mixin WithWishPkMixin implements WithWishPk {
//   @override
//   late int wishPk;
// }

// mixin WithCardPkMixin implements WithCardPk {
//   @override
//   late int cardPk;
// }

abstract class CardsListLengthChangedState implements WithUserPk, WithWishPk {
  int get oldLength;
  int get newLength;
}

class InitialState extends WishlistState {
  const InitialState();
}

class WishTitleChangedState extends WishlistState implements WithUserPk, WithWishPk {
  final Wish newWish;
  @override
  final String userPk;

  const WishTitleChangedState({
    required this.newWish,
    required this.userPk,
  });

  @override
  int get wishPk => newWish.pk;
}

class CardChangedState<T extends Card> extends WishlistState implements WithCardPk, WithUserPk, WithWishPk {
  final T newCard;
  @override
  final String userPk;
  @override
  final int wishPk;

  const CardChangedState({
    required this.newCard,
    required this.userPk,
    required this.wishPk,
  });

  @override
  int get cardPk => newCard.pk;
}

class WishMovedState extends WishlistState implements WithUserPk, WithWishPk {
  final Wish movedWish;
  @override
  final String userPk;
  final List<Wish> oldOrder;
  final List<Wish> newOrder;

  WishMovedState({
    required this.movedWish,
    required this.userPk,
    required this.oldOrder,
    required this.newOrder,
  });

  @override
  int get wishPk => movedWish.pk;
}

class CardAddedState extends WishlistState implements CardsListLengthChangedState, WithCardPk {
  final Card addedCard;
  @override
  final int newLength;
  @override
  final String userPk;
  @override
  final int wishPk;

  const CardAddedState({
    required this.newLength,
    required this.addedCard,
    required this.userPk,
    required this.wishPk,
  });

  @override
  int get oldLength => newLength - 1;

  @override
  int get cardPk => addedCard.pk;
}

class CardMovedState extends WishlistState implements WithCardPk, WithUserPk, WithWishPk {
  @override
  final String userPk;
  @override
  final int wishPk;
  @override
  final int cardPk;
  final int newIndex;

  const CardMovedState({
    required this.userPk,
    required this.wishPk,
    required this.cardPk,
    required this.newIndex,
  });
}

class CardDeletedState extends WishlistState implements CardsListLengthChangedState, WithCardPk {
  final Card deletedCard;
  @override
  final int newLength;
  @override
  final String userPk;
  @override
  final int wishPk;

  CardDeletedState({
    required this.newLength,
    required this.deletedCard,
    required this.userPk,
    required this.wishPk,
  });

  @override
  int get oldLength => newLength + 1;

  @override
  int get cardPk => deletedCard.pk;
}

class WishlistBloc extends Cubit<WishlistState> {
  WishlistBloc()
      : _users = UsersSet(),
        super(const InitialState());

  WishlistBloc.fromUsers(UsersSet users)
      : _users = users,
        super(const InitialState());

  static WishlistBloc of(BuildContext context) {
    return BlocProvider.of<WishlistBloc>(context, listen: false);
  }

  String? currentUser;

  final UsersSet _users;

  Map<String, User> get users => _users.toMap();

  Wish? wishOfUser(String permanentName, int wishPk) {
    return _users[permanentName]?.wishes.firstWhere((e) => e.pk == wishPk);
  }

  T? cardOf<T extends Card>(String userPk, int wishPk, int cardPk) {
    return wishOfUser(userPk, wishPk)!.cards.firstWhere((e) => e.pk == cardPk) as T;
  }

  int? indexOfCard(String userPk, int wishPk, int cardPk) => wishOfUser(userPk, wishPk)?.cards.indexWhere((e) => e.pk == cardPk);

  void setTitleForWish(String userPk, int wishPk, String newTitle) {
    final newWish = wishOfUser(userPk, wishPk)!.copyWith(title: newTitle);
    final user = _users[userPk]!;

    final index = user.wishes.indexWhere((e) => e.pk == wishPk);
    user.wishes[index] = newWish;

    emit(WishTitleChangedState(newWish: newWish, userPk: userPk));
  }

  void setTextCard(String userPk, int wishPk, int cardPk, TextCard newCard) {
    wishOfUser(userPk, wishPk)!.cards.replaceFirstWhere((e) => e.pk == cardPk, newCard);

    emit(CardChangedState(newCard: newCard, userPk: userPk, wishPk: wishPk));
  }

  void moveCard(String userPk, int wishPk, int cardPk, int newIndex) {
    var w = wishOfUser(userPk, wishPk)!;
    assert(newIndex < w.cards.length);
    Card? card;
    w.cards.removeWhere((e) {
      if (e.pk == cardPk && card == null) {
        card = e;
        return true;
      }
      return false;
    });
    w.cards.insert(newIndex, card!);
    // print(w);

    emit(CardMovedState(userPk: userPk, wishPk: wishPk, cardPk: cardPk, newIndex: newIndex));
  }

  void createCard(String userPk, int wishPk, Card card) {
    final w = wishOfUser(userPk, wishPk)!;

    w.cards.add(card);

    emit(CardAddedState(newLength: w.cards.length, addedCard: card, userPk: userPk, wishPk: wishPk));
  }

  void deleteCard(String userPk, int wishPk, int cardPk) {
    final w = wishOfUser(userPk, wishPk)!;
    final c = w.cards.firstWhere((e) => e.pk == cardPk);

    w.cards.remove(c);
    
    emit(CardDeletedState(newLength: w.cards.length, deletedCard: c, userPk: userPk, wishPk: wishPk));
  }
}
