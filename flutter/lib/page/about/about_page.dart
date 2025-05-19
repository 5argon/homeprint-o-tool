import 'package:flutter/material.dart';
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Homeprint O'Tool",
                style: titleStyle,
              ),
              const SizedBox(height: 24),
              const Text(
                "A desktop software that creates duplex uncut sheet image files out of individual card graphics.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                "Developer",
                style: subtitleStyle,
              ),
              const SizedBox(height: 8),
              const Text(
                "5argon",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                "Contact",
                style: subtitleStyle,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 24),
              const Text(
                "You can post issues and feature requests on the Issues section in the GitHub repository, or send an email.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
