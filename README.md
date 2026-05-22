# 🎬 Zero Stream - v2.3.1

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-2.3.1-green.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming aggregator designed for both mobile and desktop. It provides a seamless interface to explore trending movies and TV shows with advanced filtering and an optimized playback experience.

---

## ✨ Core Features

* **Intelligent Discovery:** Explore trending content with a dynamic "Watermorphic" sliding hero section.
* **Seamless OTA Updates:** Built-in automatic update detection and background downloader for a hassle-free app experience.
* **Advance Search Logic:** Multi-layered filtering by **Media Type**, **Release Year**, and **Genre** with strict word-matching precision.
* **🖥️ Windows Browser Hub:** Specialized for TV Series on Windows, the app generates a localized Smart Hub (HTML5) that opens in your default browser, providing a dedicated episode manager.
* **📱 Smart Mobile Player:** High-performance mobile playback featuring ergonomic controls, auto-hide overlays, dynamic metadata, and integrated ad-blocking.
* **⚖️ Weighted Sorting:** Organize content by Latest Release, Ratings (High/Low), or Alphabetical Order with live filtering chips.
* **Performance First:** Zero-lag UI transitions using optimized Provider state management and lazy-loaded image caching for a smooth experience on any device.

---

## 📸 Screenshots
> **⚠️ Note:** Screenshots are coming soon!

---

## ⚙️ Setup & Installation
1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/hyper-crazy/zero_cost_streamer.git](https://github.com/hyper-crazy/zero_cost_streamer.git)
    ```
2.  **Environment & Firebase Configuration:**
    * Create a `.env` file in the root:
      ```env
      TMDB_API_KEY=your_api_key_here
      ```
    * Ensure your `google-services.json` is placed in `android/app/` for the update service and Firebase integration.
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
* Zero Stream is a metadata aggregator. It does not host media; it provides an interface to access publicly available metadata and third-party streaming links.

---

## 👨‍💻 Developed By
**Morshedul Islam Maruf** *Lead Developer* GitHub: [@hyper-crazy](https://github.com/hyper-crazy)

---

> **Note:** Zero Stream v2.3.1 is an ongoing experiment in high-performance cross-platform UI. Feel free to fork and contribute!