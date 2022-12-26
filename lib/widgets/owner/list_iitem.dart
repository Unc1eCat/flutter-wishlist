import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:wishlist_mobile/bloc/wishlist_bloc.dart';

class ListItem extends StatelessWidget {
  final String permanentName;
  final int wishPk;

  const ListItem({
    Key? key,
    required this.permanentName,
    required this.wishPk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    var bloc = BlocProvider.of<WishlistBloc>(context);
    var model = bloc.wishOfUser(permanentName, wishPk)!;
    late List<Widget> children;

    if (model.isChecked) {
      children = [
        Icon(Icons.check_rounded, color: Colors.green[600], size: 28),
        const SizedBox(width: 10),
        ClipOval(
          child: Container(
            // Placeholder for user pfp. Idk how to handle images between server and client yet
            color: Colors.grey,
            height: 30,
            width: 30,
          ),
        ),
        const SizedBox(width: 10),
      ];
    } else {
      children = [
        SizedBox(
          width: 68,
          child: Center(
            child: Icon(Icons.remove_rounded,
                color: Theme.of(context).unselectedWidgetColor),
          ),
        )
      ];
    }

    children.add(
      Text(model.title, style: Theme.of(context).textTheme.titleMedium),
    );

    return Row(children: children);
  }
}
