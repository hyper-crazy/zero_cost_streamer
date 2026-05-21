import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateService {
  Future<void> checkUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      final ref = FirebaseDatabase.instance.ref('app_update');
      final snapshot = await ref.get();

      if (!snapshot.exists) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      int remoteVersionCode = data['version_code'];
      String latestVersion = data['latest_version'];
      String apkUrl = data['apk_url'];
      String githubPage = data['github_page'];
      bool isForceUpdate = data['is_force_update'];

      String releaseNotes = (data['release_notes'] ?? "Bug fixes and performance improvements.").toString().replaceAll('\\n', '\n');

      if (remoteVersionCode > currentVersionCode) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, apkUrl, githubPage, isForceUpdate, releaseNotes);
        }
      }
    } catch (e) {
      debugPrint("Update Check Error: $e");
    }
  }

  void _showUpdateDialog(BuildContext context, String version, String apkUrl, String githubPage, bool isForce, String releaseNotes) {
    showDialog(
      context: context,
      barrierDismissible: !isForce,
      builder: (context) {
        double downloadProgress = 0.0;
        bool isDownloading = false;
        bool isDownloaded = false;
        String savedFilePath = "";

        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: !isForce,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    const Icon(Icons.system_update, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Expanded(child: Text("Update Available (v$version)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isDownloaded
                          ? "Download complete! Click 'Install Now' to update the app."
                          : "A new version of Zero Stream is ready."),

                      const SizedBox(height: 15),
                      const Text("What's New:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          releaseNotes,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),

                      if (isDownloading) ...[
                        const SizedBox(height: 20),
                        LinearProgressIndicator(value: downloadProgress / 100, color: Colors.blueAccent),
                        const SizedBox(height: 10),
                        Center(child: Text("Downloading: ${downloadProgress.toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold))),
                      ]
                    ],
                  ),
                ),
                actions: [
                  if (!isForce && !isDownloading && !isDownloaded)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Later", style: TextStyle(color: Colors.grey)),
                    ),
                  if (!isDownloading && !isDownloaded)
                    TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(githubPage);
                        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                      child: const Text("Go to GitHub", style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDownloaded ? Colors.green : Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDownloading ? null : () async {
                      if (isDownloaded) {
                        await OpenFilex.open(savedFilePath);
                        return;
                      }

                      setState(() => isDownloading = true);

                      try {
                        Directory? dir = await getExternalStorageDirectory();
                        if (dir != null) {
                          savedFilePath = "${dir.path}/ZeroStream_v$version.apk";

                          await Dio().download(
                            apkUrl,
                            savedFilePath,
                            onReceiveProgress: (received, total) {
                              if (total != -1) {
                                setState(() {
                                  downloadProgress = (received / total) * 100;
                                });
                              }
                            },
                          );

                          setState(() {
                            isDownloading = false;
                            isDownloaded = true;
                          });
                        }
                      } catch (e) {
                        setState(() {
                          isDownloading = false;
                          isDownloaded = false;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download failed. Please try GitHub.")));
                        }
                      }
                    },
                    child: Text(isDownloaded ? "Install Now" : (isDownloading ? "Downloading..." : "Update Now")),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}