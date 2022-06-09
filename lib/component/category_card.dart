import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/component/main_stat.dart';
import 'package:dusty_dust/model/stat_and_status_model.dart';
import 'package:dusty_dust/utils/data_utils.dart';
import 'package:flutter/material.dart';

import '../const/colors.dart';

class CategoryCard extends StatelessWidget {
  final Color darkColor;
  final Color lightColor;
  final String region;
  final List<StatAndStatusModel> models;

  const CategoryCard({
    required this.darkColor,
    required this.lightColor,
    required this.region,
    required this.models,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: MainCard(
        backgroundColor: lightColor,
        child: LayoutBuilder(builder: (context, constraints) {
          // covariant.maxWidth
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '종류별 통계',
                backgroundColor: darkColor,
              ),
              Expanded(
                child: ListView(
                  //좌우 스크롤
                  scrollDirection: Axis.horizontal,
                  //살짝 스와이프시 페이지 개념으로 스크롤이동
                  physics: PageScrollPhysics(),
                  children: models
                      .map((model) => MainStat(
                            category: DataUtils.getItemCodeKrString(
                                itemCode: model.itemCode),
                            imgPath: model.status.imagePath,
                            level: model.status.label,
                            stat: '${model.stat.getLevelFromRegion(
                              region,
                            )}${DataUtils.getUnitFromDataType(itemCode: model.itemCode)}',
                            width: constraints.maxWidth / 3,
                          ))
                      .toList(),
                  // List.generate(
                  //   20,
                  //   (index) => MainStat(
                  //     category: '미세먼지',
                  //     imgPath: 'asset/img/best.png',
                  //     level: '최고',
                  //     stat: '0㎍/㎥',
                  //     //LayoutBuilder의 constraints를 통해 가져온 카드의 전체영역의 1/3을 찾을수 있음
                  //     width: constraints.maxWidth / 3,
                  //   ),
                  // ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
