import 'package:dio/dio.dart';
import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/component/category_card.dart';
import 'package:dusty_dust/component/hourly_card.dart';
import 'package:dusty_dust/component/main_app_bar.dart';
import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/component/main_drawer.dart';
import 'package:dusty_dust/component/main_stat.dart';
import 'package:dusty_dust/const/colors.dart';
import 'package:dusty_dust/const/data.dart';
import 'package:dusty_dust/const/regions.dart';
import 'package:dusty_dust/const/status_level.dart';
import 'package:dusty_dust/model/stat_and_status_model.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/repository/stat_repository.dart';
import 'package:dusty_dust/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    scrollController.addListener(scrollListener);
  }

  @override
  dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<Map<ItemCode, List<StatModel>>> fetchData() async {
    // Map<ItemCode, List<StatModel>> stats = {};

    List<Future> futures = [];

    for (ItemCode itemCode in ItemCode.values) {
      futures.add(
        StatRepository.fetchData(
          itemCode: itemCode,
        ),
      );
    }
    //await을 밖에 줌으로써 1개의 요청후 대기가 아닌 for문을 순차적으로 돌며 요청을 사실상 동시에 함,결과는 for문을 돈 순차적으로 쌓임
    final results = await Future.wait(futures);

    for (int i = 0; i < results.length; i++) {
      // ItemCode
      final key = ItemCode.values[i];
      //List<StatModel>
      final value = results[i];

      final box = Hive.box<StatModel>(key.name);

      for (StatModel stat in value) {
        box.put(stat.dataTime.toString(), stat);
      }
    }

    return ItemCode.values.fold<Map<ItemCode, List<StatModel>>>(
      {},
      (previousValue, itemCode) {
        final box = Hive.box<StatModel>(itemCode.name);

        previousValue.addAll({
          itemCode: box.values.toList(),
        });

        return previousValue;
      },
    );
  }

  scrollListener() {
    bool isExpanded = scrollController.offset < 500 - kToolbarHeight;

    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<ItemCode, List<StatModel>>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // 에러가 있을때
          return Scaffold(
            body: Center(
              child: Text(
                '에러가 있습니다.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          // 로딩상태
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        Map<ItemCode, List<StatModel>> stats = snapshot.data!;
        StatModel pm10RecentStat = stats[ItemCode.PM10]![0];

        //미세먼지 최근 데이터의 현재 상태
        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: pm10RecentStat.seoul,
          itemCode: ItemCode.PM10,
        );

        final ssModel = stats.keys.map((key) {
          final value = stats[key]!;
          final stat = value[0];

          return StatAndStatusModel(
            itemCode: key,
            status: DataUtils.getStatusFromItemCodeAndValue(
              value: stat.getLevelFromRegion(region),
              itemCode: key,
            ),
            stat: stat,
          );
        }).toList();

        return Scaffold(
          drawer: MainDrawer(
            darkColor: status.darkColor,
            lightColor: status.lightColor,
            onRegionTap: (String region) {
              setState(() {
                this.region = region;
              });
              //드로워도 하나의 화면으로 인식하기떄문에 pop 사용 가능
              Navigator.of(context).pop();
            },
            selectedRegion: region,
          ),
          body: Container(
            color: status.primaryColor,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                MainAppBar(
                  region: region,
                  stat: pm10RecentStat,
                  status: status,
                  dateTime: pm10RecentStat.dataTime,
                  isExpanded: isExpanded,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CategoryCard(
                        region: region,
                        models: ssModel,
                        darkColor: status.darkColor,
                        lightColor: status.lightColor,
                      ),
                      const SizedBox(height: 16.0),
                      ...stats.keys.map(
                        (itemCode) {
                          final stat = stats[itemCode]!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: HourlyCard(
                              darkColor: status.darkColor,
                              lighColor: status.lightColor,
                              category: DataUtils.getItemCodeKrString(
                                itemCode: itemCode,
                              ),
                              stats: stat,
                              region: region,
                            ),
                          );
                        },
                      ).toList(),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
