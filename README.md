# 🎬 Zero Stream - v2.3.0

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-2.3.0-green.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming aggregator. The v2.3.0 update introduces a seamless OTA (Over-The-Air) in-app update experience, alongside surgical search precision and refined player ergonomics.

---

## 🚀 What's New in v2.3.0
This major release ensures you never miss a new feature or bug fix:

* **🔄 Seamless In-App Auto Updates:** No need to check GitHub manually anymore. The app now automatically detects new versions via Firebase, downloads the latest release securely in the background, and prompts the native Android package installer—all without leaving the app.
* **⚡ Background Downloader:** Built with robust internal storage management to safely download and initialize updates without crashing or triggering aggressive system kills.

*(Previous highlights from v2.2.0 including the Windows Browser Hub, Ultra-Precise Search Engine, and Stealth Ad-Blocker are now fully stabilized in this build).*

---

## ✨ Core Features
* **Intelligent Discovery:** Explore trending content with a dynamic "Watermorphic" sliding hero section.
* **Advance Search Logic:** Multi-layered filtering by **Media Type**, **Release Year (1900–2026)**, and **Genre** with strict word-matching.
* **🖥️ Windows Browser Hub:** For TV Series on Windows, the app generates a localized Smart Hub (HTML5) that opens in your default browser.
* **📱 Smart Mobile Player:** Ergonomic controls, auto-hide overlays, and dynamic logical metadata titles.
* **⚖️ IMDb Weighted Sorting:** Sort by Latest Release, High/Low Rating, or Alphabetical Order with live filtering chips.
* **Performance First:** Zero-lag UI transitions using optimized Provider state management and lazy-loaded image caching.

---

## 📸 Screenshots
> **⚠️ Note:** Screenshots are coming soon!

---

## ⚙️ Setup & Installation
1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/hyper-crazy/zero_cost_streamer.git](https://github.com/hyper-crazy/zero_cost_streamer.git)
    ```
2.  **Environment & Firebase Configuration:** * Create a `.env` file in the root:
      ```env
      TMDB_API_KEY=your_api_key_here
      ```
    * Ensure your `google-services.json` is placed in `android/app/` for the update service to connect to Firebase Realtime Database.
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
* **Cloud & Updates:** Firebase Realtime Database, Dio, Open Filex
* **WebView Engines:** Webview Flutter (Mobile) & Native Browser Hub (Windows)
* **Networking:** HTTP & Connectivity Plus

---

## 📜 Attribution & Legal
* This app uses the TMDB API but is not endorsed or certified by TMDB.
* Zero Stream is an aggregator. It does not host media; it provides a seamless interface to access publicly available metadata and third-party streaming links.

---

## 👨‍💻 Developed By
**Morshedul Islam Maruf** *Lead Developer* GitHub: [@hyper-crazy](https://github.com/hyper-crazy)

---

> **Note:** Zero Stream v2.3.0 is an ongoing experiment in high-performance cross-platform UI. Feel free to fork and contribute!