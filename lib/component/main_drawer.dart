import 'package:dusty_dust/const/regions.dart';
import 'package:flutter/material.dart';

typedef OnRegionTap = void Function(String region);

class MainDrawer extends StatelessWidget {
  final OnRegionTap onRegionTap;
  final String selectedRegion;
  final Color darkColor;
  final Color lightColor;

  const MainDrawer({
    required this.onRegionTap,
    required this.selectedRegion,
    required this.darkColor,
    required this.lightColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              '지역 선택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          //...을 통해 리스트안에 리스트를 담을수 있게 변환
          ...regions
              .map(
                (e) => ListTile(
                  tileColor: Colors.white,
                  //선택시 배경색
                  selectedTileColor: lightColor,
                  //선택시 text색
                  selectedColor: Colors.black,
                  //선택된 상태 조절
                  selected: e == selectedRegion,
                  onTap: () {
                    onRegionTap(e);

                  },
                  title: Text(
                    e,
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
