import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class TestDraggable extends StatefulWidget {
  const TestDraggable({Key? key}) : super(key: key);

  @override
  State<TestDraggable> createState() => _TestDraggableState();
}

class _TestDraggableState extends State<TestDraggable> {
  TextEditingController controller = TextEditingController();
  List<String> items = [];
  int acceptedData = 0;
  final double _iconSize = 90;
  List<Widget> _tiles = [];
  List<String> listTest = [];

  @override
  void initState() {
    super.initState();
  }

  void _onReorder(int oldIndex, int newIndex) {
    String word = listTest.removeAt(oldIndex);
    listTest.insert(newIndex, word);
    setState(() {
      print('oldIndex $oldIndex');
      print('newIndex $newIndex');

      Widget row = _tiles.removeAt(oldIndex);
      _tiles.insert(newIndex, row);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TestDraggable!'),
      ),
      body: Column(
        children: [
          Container(
            width: 400,
            color: Colors.grey.withOpacity(0.5),
            child: _tiles.isNotEmpty
                ? Align(
              alignment: Alignment.center,
                    child: ReorderableWrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      needsLongPressDraggable: false,
                      padding: const EdgeInsets.all(8),
                      children: _tiles,
                      onReorder: _onReorder,
                      onNoReorder: (int index) {
                        //this callback is optional
                        debugPrint(
                            '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                      },
                      onReorderStarted: (int index) {
                        //this callback is optional
                        debugPrint(
                            '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
                      },
                    ),
                  )
                : Center(child: Text('Empty')),
          ),
          TextField(
            decoration: InputDecoration(),
            controller: controller,
            onSubmitted: (s) {
              setState(() {
                listTest.add(controller.text);
                _tiles.add(
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white),
                    width: 20 + (controller.text.length.toDouble() * 7),
                    height: 37,
                    child: Center(
                      child: Container(child: Text('${controller.text}')),
                    ),
                  ),
                );
                controller.text = '';
              });
            },
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
