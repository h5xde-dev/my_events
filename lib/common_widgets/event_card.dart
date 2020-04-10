import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 5, top: 10),
      height: 130,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Дегустация Chabaco',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  'Магнитогорск, Ленина 228',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.person
                    ),
                    Text(
                      ' HookahService',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 15),
                    Icon(
                      Icons.people
                    ),
                    Text(
                      ' 41',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*3*/
          IconButton(
            icon: Icon(Icons.gps_not_fixed),
            color: Colors.deepPurple,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}