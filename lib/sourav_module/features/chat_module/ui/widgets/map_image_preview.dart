import 'package:agora_chat_module/sourav_module/features/chat_module/models/messages.dart';
import 'package:flutter/material.dart';

class MapImagePreview extends StatelessWidget {
  const MapImagePreview({Key? key, required this.locationData})
      : super(key: key);

  final LocationData locationData;

  String get _constructUrl => Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'center': '${locationData.latitude},${locationData.longitude}',
          'zoom': '18',
          'size': '700x500',
          'maptype': 'roadmap',
          'key': 'AIzaSyANCUHT3xrElMtu08ivMlbPpQzJJ7O7MUA',
          'markers':
              'color:red|${locationData.latitude},${locationData.longitude}'
        },
      ).toString();

  @override
  Widget build(BuildContext context) {
    // return Image.network(
    //   _constructUrl,
    //   height: 300.0,
    //   width: 600.0,
    //   fit: BoxFit.fill,
    // );
    return const Center(
      child: Text(
        'Static Map Image',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
