import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

/// 自定义绘制三角形
class Triangle extends PaintContent {
  Triangle();

  Offset startPoint = Offset.zero;

  Offset A = Offset.zero;
  Offset B = Offset.zero;
  Offset C = Offset.zero;

  @override
  void startDraw(Offset startPoint) => this.startPoint = startPoint;

  @override
  void drawing(Offset nowPoint) {
    A = Offset(
        startPoint.dx + (nowPoint.dx - startPoint.dx) / 2, startPoint.dy);
    B = Offset(startPoint.dx, nowPoint.dy);
    C = nowPoint;
  }

  @override
  void draw(Canvas canvas, Size size, bool deeper) {
    final Path path = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  Triangle copy() => Triangle();
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 绘制控制器
  final DrawingController _drawingController = DrawingController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  /// 获取画板数据 `getImageData()`
  Future<void> _getImageData() async {
    final Uint8List? data =
        (await _drawingController.getImageData())?.buffer.asUint8List();
    if (data == null) {
      print('获取图片数据失败');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext c) {
        return Material(
          color: Colors.transparent,
          child:
              InkWell(onTap: () => Navigator.pop(c), child: Image.memory(data)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Drawing Test'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.check), onPressed: _getImageData)
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background:
                  Container(width: 400, height: 400, color: Colors.white),
              foreground: Image.asset('images/drawing_horse.png', width: 400, height: 400),
              showDefaultActions: true,
              showDefaultTools: true,
              defaultToolsBuilder: (Type t, _) {
                return DrawingBoard.defaultTools(t, _drawingController)
                  ..insert(
                    1,
                    DefToolItem(
                      icon: Icons.change_history_rounded,
                      isActive: t == Triangle,
                      onTap: () =>
                        _drawingController.setPaintContent = Triangle(),
                    ),
                  );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SelectableText(
              'https://github.com/xSILENCEx/flutter_drawing_board',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
