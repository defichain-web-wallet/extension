import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

class TestDrug extends StatefulWidget {
  const TestDrug({Key? key}) : super(key: key);

  @override
  State<TestDrug> createState() => _TestDrugState();
}

class _TestDrugState extends State<TestDrug> {
  final items = [
    'Item22 1',
    'Item 2asdas',
    'Item 3',
    'Im 4',
    'Items 5',
    'Item 6',
    'm 7',
    'Item 8',
  ];

  static List<String> listOfImages =
  List.generate(12, (index) => 'assets/${index + 1}.jpeg');
  List<DraggableGridItem> listOfWidgets = List.generate(
    listOfImages.length,
        (index) =>
        DraggableGridItem(
          child: Container(
            padding: EdgeInsets.only(
              left: 4.0,
              right: 4.0,
              top: 8.0,
            ),
            child: Text('${listOfImages[index]}'),
          ),
        ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TestDrug!'),
      ),
      body: Container(
        child: DraggableGridViewBuilder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: MediaQuery
                .of(context)
                .size
                .width / (MediaQuery
                .of(context)
                .size
                .height / 3),
          ),
          children: listOfWidgets,
          isOnlyLongPress: false,
          dragCompletion: (List<DraggableGridItem> list, int beforeIndex,
              int afterIndex) {
            print('onDragAccept: $beforeIndex -> $afterIndex');
          },
          dragFeedback: (List<DraggableGridItem> list, int index) {
            return Container(
              child: list[index].child,
              width: 200,
              height: 150,
            );
          },
          dragPlaceHolder: (List<DraggableGridItem> list, int index) {
            return PlaceHolderWidget(
              child: Container(
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  void _updateMyItems(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
  }
}
