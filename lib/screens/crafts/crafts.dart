import 'dart:async';
import 'dart:convert';

import 'package:arangu/constants/colors.dart';
import 'package:arangu/screens/crafts/CraftDetails.dart';
import 'package:arangu/screens/events/widgets/EventCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<Post> postFromJson(String str) =>
    List<Post>.from(json.decode(str).map((x) => Post.fromMap(x)));

class Post {
  Post(
      {required this.id,
      required this.craft_name,
      required this.craft_place,
      required this.craft_description,
      required this.latitude,
      required this.longitude,
      required this.rating,
      required this.image});

  final int id;
  final String? craft_name;
  final String? craft_description;
  final String? craft_place;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final String? image;

  factory Post.fromMap(Map<String, dynamic> json) => Post(
      id: json['id'],
      craft_name: json['craft_name'],
      craft_description: json['craft_description'],
      craft_place: json['craft_place'],
      latitude: json['latitude'],
      longitude: json['latitude'],
      rating: json['rating'],
      image: json['image']);
}

Future<List<Post>> fetchPost() async {
  final url = "${constants.BaseUrl}/crafts/all/";
  final response = await http.get(Uri.parse("${url}"));

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

    return parsed.map<Post>((json) => Post.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load album');
  }
}

class CraftsPage extends StatefulWidget {
  const CraftsPage({Key? key}) : super(key: key);

  @override
  State<CraftsPage> createState() => _CraftsPageState();
}

class _CraftsPageState extends State<CraftsPage> {
  late Future<List<Post>> futurePost;
  @override
  void initState() {
    futurePost = fetchPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: futurePost,
      builder: (context, snapshot) {
        // print("${snapshot.data![1].image}");
        if (snapshot.hasData) {
          return ListView.separated(
            separatorBuilder: (_, index) => Divider(),
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) => InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CraftDetails(),
                        settings:
                            RouteSettings(arguments: snapshot.data![index])));
              },
              child: Container(
                  child: EventCard(
                name: "${snapshot.data![index].craft_name}",
                place: "${snapshot.data![index].craft_place}",
                imageUrl: "${snapshot.data![index].image}",
              )),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
