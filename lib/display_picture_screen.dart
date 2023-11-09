import 'package:flutter/material.dart';
import 'dart:io';
import 'menu_description.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('capture screen')),
      // Use a Container to fill the screen with the image
      body: SizedBox(
        // The Container should expand to the full screen size
        width: double.infinity,
        height: double.infinity,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover, // This will cover the entire screen area
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Show a confirmation dialog
            final bool confirmed = await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('사진 확인'),
                    content: const Text('이 사진을 사용하시겠습니까?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('아니오'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('예'),
                      ),
                    ],
                  ),
                ) ??
                false;

            // If the user confirmed, then navigate to the DescriptionPage
            if (confirmed) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DescriptionPage(
                    imagePath: imagePath,
                  ),
                ),
              );
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
