import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_dropdown_controller.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:dio/dio.dart';

import 'model/pagination_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  late final dio = Dio();
  late SearchableDropdownController<int> controller =
      SearchableDropdownController(pageListener);

  void pageListener(page, searchKey) async {
    print("object");
    final paginatedList = await getAnimeList(page: page, key: searchKey);
    final data = paginatedList?.animeList
        ?.map((e) => SearchableDropdownMenuItem(
            value: e.malId, label: e.title ?? '', child: Text(e.title ?? '')))
        .toList();
    controller.appendNewPage(data!);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Searchable Dropdown Example'),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 20),
            /////////////
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: SearchableDropdown<int>.paginated(
                isDialogExpanded: false,
                hintText: const Text('Paginated request'),
                margin: const EdgeInsets.all(15),
                controller: controller,
                requestItemCount: 25,
                onChanged: (int? value) {
                  debugPrint('$value');
                },
              ),
            ),

            ////////////
          ],
        ),
      ),
    );
  }

  Future<AnimePaginatedList?> getAnimeList(
      {required int page, String? key}) async {
    try {
      String url = "https://api.jikan.moe/v4/anime?page=$page";
      if (key != null && key.isNotEmpty) url += "&q=$key";
      var response = await dio.get(url);
      if (response.statusCode != 200) throw Exception(response.statusMessage);
      return AnimePaginatedList.fromJson(response.data);
    } catch (exception) {
      throw Exception(exception);
    }
  }
}
