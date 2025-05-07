import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/leaflet.dart';

class LeafletContent extends StatelessWidget {
  final List<Leaflet> leaflets;
  const LeafletContent({super.key, required this.leaflets});

  @override
  Widget build(BuildContext context) {
    if (leaflets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No electronic leaflets available')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children:
            leaflets.map((leaflet) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(
                    leaflet.productLeafletInformation,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leaflet.lang.isNotEmpty)
                        Text('Language: ${leaflet.lang}'),
                      if (leaflet.linkType.isNotEmpty)
                        Text('Link Type: ${leaflet.linkType}'),
                      if (leaflet.targetUrl.isNotEmpty)
                        Text(
                          'URL: ${leaflet.targetUrl}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing:
                      leaflet.fullPdfUrl != null
                          ? IconButton(
                            icon: const Icon(Icons.open_in_new),
                            tooltip: 'Open PDF',
                            onPressed: () async {
                              final url = leaflet.fullPdfUrl!;
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                          )
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }
}
