import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({
    Key? key,
    required this.title,
    required this.artist,
    required this.url,
  }) : super(key: key);

  final String title;
  final String artist;
  final String url;

  @override
  State<StatefulWidget> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  bool fetching = false;
  String? lyrics;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    setState(() => fetching = true);

    final webScraper = WebScraper('https://genius.com');

    String path = widget.url.split('genius.com/')[1];
    String fullLyrics = '';
    if (await webScraper.loadWebPage('/$path?react=1')) {
      webScraper.loadFromString(webScraper.getPageContent().replaceAll('<br>', '\n'));
      var element = webScraper.getElement("div[data-lyrics-container]", ['data-lyrics-container']);
      for (var section in element) {
        fullLyrics += section['title'] + '\n';
      }
      setState(() {
        lyrics = fullLyrics;
        fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.artist,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: fetching
            ? const Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [CircularProgressIndicator(value: null)],
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    child: SelectableText(
                      lyrics ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
