import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_dropdown_controller.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:dio/dio.dart';

import 'model/pagination_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  late final dio = Dio();
  late final SearchableDropdownController<int> controller =
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
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(fontSize: 16),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          hintStyle: TextStyle(
            color: const Color(0xffcecece),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 1, color: Color(0xffcbcbcb)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 1, color: Colors.orange),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 1, color: Colors.orange),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Searchable Dropdown Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 0.8, color: Colors.grey.shade500)),
                    child: SearchableDropdown<int>.paginated(
                      local: "en",
                      hintText: const Text('Paginated request'),
                      controller: controller,
                      requestItemCount: 25,
                      isEnabled: true,
                      dialogWidth: 200,
                      width: 200,
                      onChanged: (int? value) {
                        debugPrint('$value');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
