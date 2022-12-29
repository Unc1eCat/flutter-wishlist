import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';
import 'package:wishlist_mobile/models.dart';
import 'package:wishlist_mobile/screens/wishlist_screen.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static MyAppState? of(BuildContext context) => context.findRootAncestorStateOfType<MyAppState>();

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late WishlistBloc bloc;
  late int cardCount; // Calculated based on device width

  @override
  void initState() {
    var u = UsersSet();
    u.add(
      User(
          permanentName: 'abc',
          wishes: [
            Wish(pk: 0, title: 'Harry Styles Vinyls', cards: [
              TextCard(pk: 1, text: "I already have Fine Line and Harry Styles on black vinyl and Harry's House on mint vinyl, so buy any other color."),
              TextCard(pk: 2, text: "UwU."),
              ImageCard(
                  pk: 3,
                  image: NetworkImage(
                      'https://cdn.shoplightspeed.com/shops/634895/files/45980186/1600x2048x2/harry-styles-harrys-house-exclusive-yellow-vinyl.jpg'),
                  textPosition: CardRelativePosition.below,
                  text: 'I would really like the one above'),
              TextCard(pk: 4, text: "😪😝🥵😈👍👍👍🎸🎹💿💿💿"),
            ]),
            Wish(
              pk: 1,
              title: 'Cherry Gum',
            ),
            Wish(
              pk: 2,
              title: 'Decorative Bats',
            ),
            Wish(
              pk: 3,
              title: 'Vibin\' Clothes',
            ),
          ],
          discoveryName: 'abc',
          displayName: 'abc'),
    );

    bloc = WishlistBloc.fromUsers(u);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: LocalHeroScope(
        curve: Curves.easeInOut,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData.dark().copyWith(
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.amberAccent[100],
              selectionHandleColor: Colors.amberAccent[100],
              selectionColor: Colors.orange[300]?.withOpacity(0.4),
            ),
            primaryColor: Colors.pinkAccent,
            textTheme: ThemeData.dark().textTheme.copyWith(
                  titleMedium: const TextStyle(fontSize: 18, letterSpacing: 0.5),
                  bodyMedium: const TextStyle(fontSize: 16),
                ),
          ),
          builder: (context, child) => Provider<MediaQueryData>(
            create: (_) => MediaQuery.of(context),
            child: child
          ),
          home: WishlistScreen(),
        ),
      ),
    );
  }
}
