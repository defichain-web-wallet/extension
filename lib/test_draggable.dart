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
    // listTest = <String>[
    //   'Container',
    //   'filter_2',
    //   'filter_3',
    //   'filter_4',
    //   'filter_5',
    //   'filter_6',
    //   'filter_7',
    //   'filter_8',
    //   'filter_9',
    // ];
    // _tiles = <Widget>[
    //   Container(
    //     width: 40,
    //     height: 40,
    //     color: Colors.amber,
    //   ),
    //   Icon(Icons.filter_2, size: _iconSize),
    //   Icon(Icons.filter_3, size: _iconSize),
    //   Icon(Icons.filter_4, size: _iconSize),
    //   Icon(Icons.filter_5, size: _iconSize),
    //   Icon(Icons.filter_6, size: _iconSize),
    //   Icon(Icons.filter_7, size: _iconSize),
    //   Icon(Icons.filter_8, size: _iconSize),
    //   Icon(Icons.filter_9, size: _iconSize),
    // ];
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('TestDraggable!'),
      ),
      body: Column(
        children: [
          Container(
            child: _tiles.isNotEmpty
                ? ReorderableWrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
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
                  )
                : Center(child: Text('Empty')),
          ),
          Container(
            child: Center(
              child: _tiles.isNotEmpty
                  ? _tiles[0]
                  : Center(
                      child: Text('Empty'),
                    ),
            ),
          ),
          Expanded(
            child: Container(
              child: listTest.isNotEmpty
                  ? ListView.builder(
                      controller: ScrollController(),
                      itemCount: listTest.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Text(listTest[index]),
                        );
                      },
                    )
                  : Center(
                      child: Text('Empty'),
                    ),
            ),
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
                      color: Colors.white
                    ),
                    width: 20 + (controller.text.length.toDouble() * 7),
                    height: 37,
                    child: Center(child: Text('${controller.text}'),),
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
