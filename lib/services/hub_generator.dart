import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content.dart';
import '../utils/constants.dart';
import '../services/tmdb_api.dart';

class HubGenerator {
  static Future<void> generateAndLaunch(Content content, int? season, int? episode) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/zero_stream_hub.html');
    final TmdbApi api = TmdbApi();

    try {
      final details = await api.getDetails(content.id, 'tv');
      final List seasons = details['seasons'] ?? [];
      String seasonOptions = "";
      String episodesDataJs = "const episodesData = {};\n";

      for (var s in seasons) {
        int sNum = s['season_number'];
        if (sNum == 0) continue;
        seasonOptions += "<option value='$sNum' ${sNum == (season ?? 1) ? 'selected' : ''}>Season $sNum</option>";
        final episodes = await api.getEpisodes(content.id, sNum);
        String epListJs = episodes.map((e) => "{n: ${e['episode_number']}, title: '${e['name'].toString().replaceAll("'", "\\'")}'}").toList().toString();
        episodesDataJs += "episodesData[$sNum] = $epListJs;\n";
      }

      String htmlContent = """
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="referrer" content="no-referrer">
        <title>Zero Stream Hub | ${content.title}</title>
        <style>
          :root { --primary: #01B4E4; --bg: #020d18; --sidebar: #0b1622; --card: rgba(255,255,255,0.05); }
          body { margin: 0; padding: 0; background: var(--bg); color: white; font-family: 'Segoe UI', sans-serif; display: flex; height: 100vh; overflow: hidden; }
          .sidebar { width: 350px; background: var(--sidebar); display: flex; flex-direction: column; border-right: 1px solid rgba(255,255,255,0.1); }
          .header { padding: 30px 20px; border-bottom: 1px solid rgba(255,255,255,0.05); }
          .header h1 { font-size: 1.3rem; margin: 0; color: var(--primary); }
          .season-selector { width: 100%; padding: 12px; margin-top: 15px; background: #1a2a3a; color: white; border: 1px solid var(--primary); border-radius: 8px; cursor: pointer; }
          .ep-list { flex: 1; overflow-y: auto; padding: 15px; }
          .ep-card { background: var(--card); padding: 15px; margin-bottom: 10px; border-radius: 10px; cursor: pointer; transition: 0.3s; display: flex; flex-direction: column; border: 1px solid transparent; }
          .ep-card:hover { background: rgba(1, 180, 228, 0.1); border-color: var(--primary); }
          .ep-card.active { background: linear-gradient(45deg, var(--primary), #005a8d); border: none; }
          .ep-label { font-size: 0.9rem; font-weight: bold; }
          .ep-title { font-size: 0.75rem; color: #abb7c4; margin-top: 4px; }
          .main-view { flex: 1; background: #000; position: relative; }
          iframe { width: 100%; height: 100%; border: none; }
        </style>
      </head>
      <body>
        <div class="sidebar">
          <div class="header"><h1>${content.title}</h1><select class="season-selector" id="seasonSelect" onchange="loadNewSeason(this.value)">$seasonOptions</select></div>
          <div class="ep-list" id="epList"></div>
        </div>
        <div class="main-view"><iframe id="player" allowfullscreen referrerpolicy="no-referrer"></iframe></div>
        <script>
          $episodesDataJs
          const tmdbId = '${content.id}';
          const baseUrl = '${AppConstants.vidsrcBaseUrl}';
          function updateSidebarUI(s, e) {
            document.querySelectorAll('.ep-card').forEach(c => c.classList.remove('active'));
            const activeCard = document.getElementById('ep-' + s + '-' + e);
            if(activeCard) { activeCard.classList.add('active'); activeCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' }); }
          }
          function renderEpisodes(sNum) {
            const list = document.getElementById('epList');
            const episodes = episodesData[sNum] || [];
            let html = "";
            episodes.forEach(ep => {
              html += `<div class="ep-card" id="ep-\${sNum}-\${ep.n}" onclick="play(\${sNum}, \${ep.n}, true)"><span class="ep-label">Episode \${ep.n}</span><span class="ep-title">\${ep.title}</span></div>`;
            });
            list.innerHTML = html;
          }
          function loadNewSeason(sNum) { renderEpisodes(sNum); const firstEp = episodesData[sNum][0].n; play(sNum, firstEp, true); }
          function play(s, e, pushHistory) {
            updateSidebarUI(s, e);
            document.getElementById('player').src = `\${baseUrl}/embed/tv/\${tmdbId}/\${s}/\${e}`;
            if(pushHistory) { history.pushState({ season: s, episode: e }, '', '?s=' + s + '&e=' + e); }
          }
          window.onpopstate = function(event) {
            if(event.state) { document.getElementById('seasonSelect').value = event.state.season; renderEpisodes(event.state.season); play(event.state.season, event.state.episode, false); }
          };
          window.onload = () => {
            const initialS = '${season ?? 1}'; const initialE = '${episode ?? 1}';
            document.getElementById('seasonSelect').value = initialS; renderEpisodes(initialS);
            history.replaceState({ season: initialS, episode: initialE }, '', '?s=' + initialS + '&e=' + initialE);
            play(initialS, initialE, false); 
          };
        </script>
      </body>
      </html>
      """;

      await file.writeAsString(htmlContent);
      await launchUrl(Uri.parse('file:///${file.path}'), mode: LaunchMode.externalApplication);
    } catch (e) { debugPrint("Hub Error: $e"); }
  }
}