// import 'package:flushbar/flushbar.dart';
// import 'package:flutter/material.dart';
// import 'package:noq/utils.dart';

// class DrawerNavigationPart extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _DrawerNavigationPart();
// }

// class _DrawerNavigationPart extends State<DrawerNavigationPart> {
//   final List<Category> mainCategories = Categories.categoryData;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: mainCategories.length,
//       itemBuilder: (BuildContext context, int index) {
//         final Category category = mainCategories[index];
//         if (category.fetchFromApi) {
//           List<Category> api = [];
//           return ExpansionTile(
//             key: PageStorageKey<Category>(category),
//             leading: Icon(category.icon),
//             title: Text(
//               category.title,
//               softWrap: false,
//               overflow: TextOverflow.ellipsis,
//             ),
//             onExpansionChanged: (bool open) async {
//               if (open) {
//                 String response = await DefaultAssetBundle.of(context)
//                     .loadString(
//                         'assets/822828-2228222-2222#category-api-mock.json');
//                 api = categoryResponseFromJson(response).data;
//                 print(api);
//               }
//             },
//             children: [
//               FutureBuilder(
//                   future: getJsonData(),
//                   builder: (context, snapshot) {
//                     final CategoryResponse categoryResponse =
//                         categoryResponseFromJson(snapshot.data);
// //                    return ListView.builder(
// //                        itemCount: 3,
// //                        itemBuilder: (BuildContext context, int index) {
// //                          return Text(index.toString());
// //                        });
//                     return ListTile(
//                         title: Text(categoryResponse.data[index].title));
//                   })
//             ],
//           );
//         } else {
//           return ListTile(
//             leading: Icon(category.icon),
//             title: Text(
//               category.title,
//               softWrap: false,
//               overflow: TextOverflow.ellipsis,
//             ),
//             onTap: () {
//               print(category.title + ' clicked');
//             },
//           );
//         }
//       },
//     );
//   }

//   Widget _buildTiles(Category root) {
//     if (root.children.isEmpty)
//       return ListTile(
//         leading: Icon(root.icon),
//         title: Text(
//           root.title,
//           softWrap: false,
//           overflow: TextOverflow.ellipsis,
//         ),
//         onTap: () {
//           print("${root.title} listTile clicked");
//         },
//       );
//     return ExpansionTile(
//       key: PageStorageKey<Category>(root),
//       leading: Icon(root.icon),
//       title: Text(
//         root.title,
//         softWrap: false,
//         overflow: TextOverflow.ellipsis,
//       ),
//       onExpansionChanged: (bool open) {
//         print("${root.title} expansionTile clicked $open");
//       },
//       children: root.children.map(_buildTiles).toList(),
//     );
//   }

//   Future<String> getJsonData() async {
//     var str = await DefaultAssetBundle.of(context)
//         .loadString('assets/822828-2228222-2222#category-api-mock.json');
//     return str;
//   }
// }
