import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';
import 'package:wishlist_mobile/models.dart';
import 'package:wishlist_mobile/screens/owner/tabs_screen.dart';
import 'package:wishlist_mobile/screens/owner/wishlist.dart';
import 'package:wishlist_mobile/utils/color.dart';

void main() {
  // debugRepaintRainbowEnabled = true;
  runApp(const MyApp());
}

ThemeData _createAppsDarkTheme() {
  final defaultDarkTheme = ThemeData.dark();
  return defaultDarkTheme.copyWith(
      useMaterial3: true,
      cardColor: Color.lerp(Colors.grey[900], Colors.blueAccent[400], 0.04),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      cardTheme: defaultDarkTheme.cardTheme.copyWith(
        color: Color.lerp(Colors.grey[900], Colors.blueAccent[400], 0.04),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.amber[200],
        selectionHandleColor: Colors.amber[200],
        selectionColor: Colors.orange[200]?.withOpacity(0.4),
      ),
      colorScheme: defaultDarkTheme.colorScheme.copyWith(
        primary: Color.lerp(Colors.pink[300], Colors.grey, 0.1),
        secondary: Colors.amber[300],
      ),
      textTheme: defaultDarkTheme.textTheme.copyWith(
        titleMedium: const TextStyle(fontSize: 18, letterSpacing: 0.5),
        bodyMedium: const TextStyle(fontSize: 16),
      ),
      buttonTheme: defaultDarkTheme.buttonTheme.copyWith(
        colorScheme: defaultDarkTheme.buttonTheme.colorScheme!.copyWith(
          primary: Color.lerp(Colors.pink[300], Colors.grey, 0.1),
        ),
      ),
      bottomNavigationBarTheme: defaultDarkTheme.bottomNavigationBarTheme.copyWith(
        unselectedItemColor: Colors.white60,
        selectedItemColor: Colors.white,
      ));
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
          theme: _createAppsDarkTheme(),
          builder: (context, child) => Builder(builder: (context) {
            return Provider<MediaQueryData>.value(value: MediaQuery.of(context), child: child);
          }),
          home: TabsScreen(),
        ),
      ),
    );
  }
}
