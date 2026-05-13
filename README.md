# 🎬 Zero Stream - v2.1.0 (Windows & Hybrid Update)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-2.1.0-orange.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming platform. The v2.1.0 update introduces **Native Windows Support** and a specialized **Hybrid Content Engine**, making it a truly cross-platform entertainment suite.

---

## 🚀 What's New in v2.1.0 (The Desktop & Stability Update)
In this version, we've broken the boundary of mobile-only streaming:

* **🖥️ Windows Desktop Support:** Fully optimized Windows client with tailored UI and native Edge WebView2 integration.
* **🛡️ Stealth Ad-Blocker:** Advanced JavaScript injection engine that suppresses pop-ups, overlays, and anti-debugging scripts from streaming providers.
* **⚡ Hybrid Player Logic:** * **Android:** Uses high-performance `webview_flutter` with landscape auto-rotation.
    * **Windows:** Uses `flutter_inappwebview` with specialized pointer-event handling for mouse interaction.
* **🔗 Dynamic Trailer Engine:** One-tap YouTube trailers. Built-in player for Mobile and external browser-link support for Windows.
* **📊 Enhanced Metadata:** Added **Vote Count** and real-time rating updates directly on the content details screen.

---

## ✨ Core Features
* **Intelligent Discovery:** Explore trending content with a dynamic "Watermorphic" sliding hero section.
* **Advance Search Engine:** Filter content by **Media Type**, **Release Year (1900–2026)**, and **Multi-Genre** selection.
* **⚖️ IMDb Weighted Sorting:** Sort results by Latest Release, Rating (High to Low), or Alphabetical Order.
* **Performance First:** Zero-lag UI transitions using optimized Provider state management and lazy-loaded image caching.

---

## 📸 Screenshots
*(Screenshots coming soon for v2.1.0)*

| Home Screen | Advance Search | Episode Selection |
| :---: | :---: | :---: |
| <img src="assets/images/Home%20Screen.jpg" width="200" alt="Home Screen" /> | <img src="assets/images/Content%20Details.jpg" width="200" alt="Content Details" /> | <img src="assets/images/Episode%20Selection.jpg" width="200" alt="Episode Selection" /> |

---

## ⚙️ Setup & Installation
1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/hyper-crazy/zero_cost_streamer.git](https://github.com/hyper-crazy/zero_cost_streamer.git)
    ```
2.  **Environment Configuration:** Create a `.env` file in the root:
    ```env
    TMDB_API_KEY=your_api_key_here
    ```
3.  **Get Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Build & Run:**
    - **Android:** `flutter build apk --release`
    - **Windows:** `flutter run -d windows`

---

## 🛠 Tech Stack
* **Framework:** Flutter (Material 3)
* **State Management:** Provider
* **WebView Engines:** Webview Flutter (Mobile) & InAppWebView (Windows)
* **Networking:** HTTP & Connectivity Plus
* **Branding:** Google Fonts (Montserrat & Lato)

---

## 📜 Attribution & Legal
* This app uses the TMDB API but is not endorsed or certified by TMDB.
* Zero Stream is an aggregator. It does not host media; it provides a seamless interface to access publicly available metadata and third-party streaming links.

---

## 👨‍💻 Developed By
**Morshedul Islam Maruf** *Lead Developer* GitHub: [@hyper-crazy](https://github.com/hyper-crazy)

---

> **Note:** Zero Stream v2.1.0 is part of an ongoing experiment in high-performance cross-platform UI. Feel free to fork and contribute!