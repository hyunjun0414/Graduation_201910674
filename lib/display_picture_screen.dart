import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:menumate/vision_api.dart';
import 'package:menumate/menu_description.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Rect? selectionRect;
  Offset? startDrag;
  Offset? currentDrag;

  void updateSelection(Offset start, Offset current) {
    setState(() {
      selectionRect = Rect.fromPoints(start, current);
    });
  }

  void completeSelection() async {
    if(!mounted) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final imageFile = File(widget.imagePath);
    final image = await decodeImageFromList(imageFile.readAsBytesSync());

    // 화면 크기와 이미지 실제 크기 사이의 비율을 계산
    final double xRatio = image.width / size.width;
    final double yRatio = image.height / size.height;

    // 선택 영역을 이미지 실제 크기에 맞게 조정
    final selectedRect = Rect.fromLTRB(
      selectionRect!.left * xRatio,
      selectionRect!.top * yRatio,
      selectionRect!.right * xRatio,
      selectionRect!.bottom * yRatio,
    );

    // 이제 'selectedRect'를 사용하여 텍스트 추출
    final extractedText = await extractTextFromImage(
        widget.imagePath, dotenv.env['APP_KEY']!, selectedRect);
    if (!mounted) return;
    print('Image size: ${image.width} x ${image.height}');
    print('Widget size: ${size.width} x ${size.height}');
    print('xRatio: $xRatio');
    print('yRatio: $yRatio');
    print(
        'Selection rect: ${selectionRect!.left}, ${selectionRect!.top}, ${selectionRect!.right}, ${selectionRect!.bottom}');
    print(
        'Transformed rect: ${selectedRect.left}, ${selectedRect.top}, ${selectedRect.right}, ${selectedRect.bottom}');

    // DescriptionPage로 화면 전환하면서 추출된 텍스트를 전달
    if (extractedText != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DescriptionPage(
            imagePath: widget.imagePath,
            extractedText: extractedText,
          ),
        ),
      );
    } else {
      // 에러 처리 (예: 사용자에게 알림 표시)
    }
  }
  @override
  void dispose() {
    // 필요한 정리 작업을 수행
    // 예를 들어, 비동기 작업을 취소하거나 리소스를 해제
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drag to select text'),
      centerTitle: true,
      ),
      body: GestureDetector(
        onPanStart: (details) {
          // Record the position where the drag starts
          setState(() {
            startDrag = details.localPosition;
            currentDrag = details.localPosition;
          });
        },
        onPanUpdate: (details) {
          // Update the position as the user drags their finger
          setState(() {
            currentDrag = details.localPosition;
            if (startDrag != null && currentDrag != null) {
              updateSelection(startDrag!, currentDrag!);
            }
          });
        },
        onPanEnd: (details) {
          // Extract text from the selected area
          completeSelection();
          // Reset the drag positions for the next selection
          setState(() {
            startDrag = null;
            currentDrag = null;
          });
        },
        child: Stack(
          children: [
            // The image
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            // The selection rectangle
            if (selectionRect != null)
              Positioned.fromRect(
                rect: selectionRect!,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
              ),
            Positioned(
              bottom: 20, // 하단에서부터 20px의 여백
              left: 130,
              right: 130,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // 현재 스택에서 이 페이지를 제거하여 이전 화면으로 돌아감
                  },
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      SizedBox(width: 10,),
                      Text('Reshoot'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
