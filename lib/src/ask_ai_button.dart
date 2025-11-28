import 'package:bb_analytics/bb_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class AskAIButton extends StatelessWidget {
  final String productName;

  // New optional parameters
  final String buttonText;
  final IconData? icon;
  final ButtonStyle? style;
  final Map<String, String> analyticsParams;

  const AskAIButton({
    super.key,
    required this.productName,
    this.buttonText = "Ask anything",
    this.icon,
    this.style,
    this.analyticsParams =
        const {}, //this would contain the acadname,uname,plan and the location
  });

  static const Map<String, String> gemUrls = {
    "drive":
        "https://gemini.google.com/gem/1zOvtZxQ1klKY0v2Q7Ww9U2L2eDOicbM_", // your Gem
  };

  @override
  Widget build(BuildContext context) {
    final Widget button = icon != null
        ? ElevatedButton.icon(
            style:
                style ??
                ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async => _openGem(context),
            icon: Icon(icon),
            label: Text(buttonText),
          )
        : ElevatedButton(
            style:
                style ??
                ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async => _openGem(context),
            child: DefaultTextStyle.merge(
              style: const TextStyle(),
              child: Text(buttonText),
            ),
          );

    return button;
  }

  Future<void> _openGem(BuildContext context) async {
    final gemUrl = gemUrls[productName];

    if (gemUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gem URL not configured")));
      return;
    }

    // Fire analytics only if parameters exist & not empty
    BBAnalytics bbAnalytics = BBAnalytics(ProductType.DRIVE);
    bbAnalytics.logEvent("ai-help-button", analyticsParams);

    // Step 1 → Info popup
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("✨ Assistant Powered by Google AI ✨"),
        content: Text(
          "Please sign in to your Google account, then ask anything about the app features when opened! ✨",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    // Step 2 → Redirect to Gem
    await launchUrl(
      Uri.parse(gemUrl),
      customTabsOptions: const CustomTabsOptions(
        showTitle: true,
        browser: CustomTabsBrowserConfiguration(prefersDefaultBrowser: true),
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
      ),
    );
  }
}
