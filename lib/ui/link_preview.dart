import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class LinkMetadata {


  static final _previews = <String,LinkMetadata>{

  };
  final String? title;
  final String? description;
  final String? imageUrl;

  LinkMetadata({this.title, this.description, this.imageUrl});



  static Future<LinkMetadata?> fetchLinkMetadata(String url) async {
    final cachedMetadata = _previews[url];
    if(cachedMetadata!=null){
      return cachedMetadata;
    }
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parse(utf8.decode(response.bodyBytes));

        // Extract metadata from meta tags
        String title = document
            .querySelector('meta[property="og:title"]')
            ?.attributes['content'] ??
            document.querySelector('title')?.text ?? '';

        if(title.isEmpty){
          //if no title is set fallback to url
          title = url;
        }

        final description = document
            .querySelector('meta[property="og:description"]')
            ?.attributes['content'] ??
            document.querySelector('meta[name="description"]')?.attributes['content'];

        final imageUrl = document.head?.querySelector('meta[name="og:image"]')
            ?.attributes['content'] ?? document.head?.querySelector('meta[property="og:image"]')
            ?.attributes['content'];
        final metadata = LinkMetadata(
          title: title,
          description: description,
          imageUrl: imageUrl,
        );
        _previews[url] = metadata;
        return metadata;
      }
    } catch (e) {
      print("Error fetching metadata: $e");
    }
    return null;
  }

  static dispose(){
    _previews.clear();
  }

}



class LinkPreview extends StatefulWidget {
  final String url;

  const LinkPreview({Key? key, required this.url}) : super(key: key);

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  Future<LinkMetadata?>? _metadataFuture;

  @override
  void initState() {
    super.initState();
    _metadataFuture = LinkMetadata.fetchLinkMetadata(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LinkMetadata?>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(color: Colors.black,),
                SizedBox(width: 16.0),
                Text('Loading...'),
              ],
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return InkWell(
            onTap: (){
              launchUrl(Uri.parse(widget.url));
            },
            child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              child: Text(
                widget.url,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        final metadata = snapshot.data!;
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: (){
              launchUrl(Uri.parse(widget.url));
            },
            child: Column(
              children: [
                if (metadata.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: metadata.imageUrl!,
                      height: 150,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (metadata.imageUrl != null) SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.title ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      metadata.description ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
