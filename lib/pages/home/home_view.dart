import 'package:flutter/material.dart';
import 'package:sibos/helpers/global.dart';
import 'package:sibos/helpers/textstyles.dart';
import 'package:sibos/widgets/category_card.dart';
import 'package:sibos/widgets/search_bar.dart';

import 'home.dart';

class HomeView extends StatelessWidget {
  final HomePageState state;
  const HomeView(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double vSpacing = 24;

    return WillPopScope(
      onWillPop: state.onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: vSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                appName,
                                style: textStyleBigBold,
                              ),
                              Text(
                                appDescription,
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          backgroundImage: AssetImage("images/duck.jpg"),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: vSpacing),
                    child: SearchBar(
                      controller: state.conSearch,
                      onSearch: state.onSearch,
                      hintText: "Cari bengkel",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: vSpacing),
                    child: Card(
                      child: Image.asset(
                        "images/duck.jpg",
                        width: double.infinity,
                        height: 256,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: vSpacing),
                    child: Text(
                      "Kategori",
                      style: textStyleBold,
                    ),
                  ),
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: vSpacing / 3),
                      child: CategoryCard(
                        title: "Bengkel roda ${(index + 1) * 2}",
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
