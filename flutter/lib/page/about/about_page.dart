import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.headlineSmall!;
    final TextStyle subtitleStyle = Theme.of(context).textTheme.titleMedium!;
    final TextStyle linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    final packageInfo = PackageInfo.fromPlatform();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Image.asset(
                  'assets/about.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
                Text(
                  "Homeprint O'Tool",
                  style: titleStyle,
                ),
                FutureBuilder(
                    future: packageInfo,
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final info = snapshot.data!;
                        return Text(
                          "Version: ${info.version}",
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
                SizedBox(
                  width: 450,
                  child: const Text(
                    "A desktop software that creates duplex uncut sheet image files out of individual card graphics.",
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "Developer",
                  style: subtitleStyle,
                ),
                const Text(
                  "5argon",
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Artwork",
                  style: subtitleStyle,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _launchURL('https://facebook.com/Sleepy.m.Sloth'),
                      child: Text(
                        "Slothy",
                        style: linkStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("GitHub / Documentation: "),
                    GestureDetector(
                      onTap: () => _launchURL(
                          'https://github.com/5argon/homeprint-o-tool'),
                      child: Text(
                        "github.com/5argon/homeprint-o-tool",
                        style: linkStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Contact",
                  style: subtitleStyle,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Email: "),
                    GestureDetector(
                      onTap: () => _launchURL('mailto:pyasry@gmail.com'),
                      child: Text(
                        "pyasry@gmail.com",
                        style: linkStyle,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "You can post issues and feature requests on the Issues section in the GitHub repository, or send an email.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
