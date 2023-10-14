import 'package:flutter/material.dart';

void main() {
  runApp(MenuDescriptionScreen());
}

class MenuDescriptionScreen extends StatelessWidget {
  MenuDescriptionScreen({super.key});

  final bool hasAllergyInfo = true; // 알러지 정보가 있는지 여부를 나타내는 변수

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Menu description',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        ),
          centerTitle: true,
        ),
        backgroundColor: Colors.lightBlueAccent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.add_a_photo,
                  size: 200,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Text(
                  'MenuName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                if (hasAllergyInfo)
                  Text(
                    '알러지 정보가 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 30,),
                Text(
                  '음식 설명',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
