import 'package:flutter/material.dart';
import 'package:teste_dev/Components/colors.dart';
import 'package:teste_dev/Menu/menu_items.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
  
}

class _MenuState extends State<Menu> {
  final controller = MenuItems();
  int currentIndex = 0;
  bool selectedItem = false;
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          background(Column(
            children: [
              Image.asset("assets/dog.png"),
              Expanded(
                flex: 3,
                child: ListView.builder(
                    itemCount: controller.items.length,
                    itemBuilder: (context, index) {
                      selectedItem = currentIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: selectedItem? primaryColor.withOpacity(0.5) : Colors.transparent
                        ),
                        child: ListTile(
                          title: Text(controller.items[index].title),
                          leading: Icon(controller.items[index].icon),

                          onTap: (){
                            setState(() {
                              currentIndex = index;
                            });
                          },
                        ),
                      );
                    }),
              ),
            ],
          )),
          Expanded(
            child: PageView.builder(
              itemCount: controller.items.length,
              onPageChanged: (value){
                setState(() {
                      currentIndex = value;
                });
              },
              itemBuilder: (context,index){
              return SizedBox(
                child: controller.items[currentIndex].page,
              );
          }))
        ],
      ),
    );
  }
}

Widget background(Widget child) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    width: 200,
    height: double.infinity,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), //arrendondar bordas
        boxShadow: [
          //sombras
          BoxShadow(
              color: Colors.grey.withOpacity(.8),
              blurRadius: 3,
              spreadRadius: 0)
        ],
        color: Colors.white),
    child: child,
  );
}
