import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CustomTabBar extends StatelessWidget {
  final String title;
  final List<String> tabs;
  final List<Widget> tabViews;

  const CustomTabBar({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      //animationDuration: Duration(milliseconds: 1000),
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.secondaryLight,
        appBar: AppBar(
          backgroundColor: AppColors.secondaryLight,
          title: Center(
              child:
                  Text(title, style: const TextStyle(color: Colors.black87))),
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: AppColors.textLightGrayLight,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                  tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashFactory: NoSplash.splashFactory,
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
            Expanded(child: TabBarView(children: tabViews)),
          ],
        ),
      ),
    );
  }
}
