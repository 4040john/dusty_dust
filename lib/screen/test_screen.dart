import 'package:dusty_dust/main.dart';
import 'package:dusty_dust/screen/test2_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TestScreen',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<Box>(
            valueListenable: Hive.box(testBox).listenable(),
            builder: (context, box, widget) {
              return Column(
                children: box.values.map((e) => Text(e)).toList(),
              );
            },
          ),
          Text(
            'TestScreen',
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);
              print('keys: ${box.keys.toList()}');
              print('Value: ${box.values.toList()}');
              print('length ${box.length}');
            },
            child: Text(
              '박스 프린트',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);

              //데이터를 생성하거나
              //업데이트 할때
              box.put(box.length, '테스트 ${box.length}');
            },
            child: Text(
              '데이터 넣기!',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);

              print(box.get(100));
            },
            child: Text(
              '특정기 값 가져오!',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final box = Hive.box(testBox);

              box.delete(box.length - 1);
            },
            child: Text(
              '특정기 값 삭제!',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Test2Screen(),
                ),
              );
            },
            child: Text(
              'test2screen',
            ),
          ),
        ],
      ),
    );
  }
}
