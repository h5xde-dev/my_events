import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.0,
      child: BottomAppBar(
        color: Colors.deepPurple,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.add_location, color: Colors.white),
              onPressed: () {
                // Navigate to the second screen using a named route.
                Navigator.pushNamed(context , '/map');
              }
            ),
            IconButton(
              icon: Icon(Icons.account_box, color: Colors.white),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}