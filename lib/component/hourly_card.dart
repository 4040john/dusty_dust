import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/utils/data_utils.dart';
import 'package:flutter/material.dart';

class HourlyCard extends StatelessWidget {
  final Color darkColor;
  final Color lighColor;
  final String category;
  final List<StatModel> stats;
  final String region;

  const HourlyCard({
    required this.category,
    required this.darkColor,
    required this.lighColor,
    required this.stats,
    required this.region,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainCard(
      backgroundColor: lighColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            backgroundColor: darkColor,
            title: '시간별 ${category}',
          ),
          Column(
            children: stats
                .map(
                  (stat) => renderRow(stat: stat),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget renderRow({required StatModel stat}) {
    final status = DataUtils.getStatusFromItemCodeAndValue(
      value: stat.getLevelFromRegion(region),
      itemCode: stat.itemCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${stat.dataTime.hour}시',
            ),
          ),
          Expanded(
            child: Image.asset(
              status.imagePath,
              height: 20,
            ),
          ),
          Expanded(
            child: Text(
              status.label,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
