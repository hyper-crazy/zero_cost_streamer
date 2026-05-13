# 🎬 Zero Stream - v2.2.0

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-2.2.0-green.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming aggregator. The v2.2.0 update focuses on surgical search precision, a revolutionary Windows playback experience, and refined mobile player ergonomics.

---

## 🚀 What's New in v2.2.0
This version bridges the gap between massive database access and user-friendly interaction:

* **🖥️ Windows Browser Hub (Exclusive):** For TV Series on Windows, the app now generates a localized **Smart Hub (HTML5)** that opens in your default browser. Navigate seasons and episodes with a professional sidebar UI while keeping the app lightweight.
* **🔍 Ultra-Precise Search Engine:** * **Word-by-Word Sync:** Search results now prioritize strict word-matching and prefix-matching logic.
    * **Full Database Integration:** Advanced filters (Year, Genre, Rating) now work seamlessly across the entire TMDB database.
* **📱 Refined Mobile Player:**
    * **Ergonomic Controls:** Next/Prev episode buttons relocated and resized for easier landscape reach.
    * **Smart UI Toggle:** Implemented an auto-hide overlay that appears/disappears with a single tap in the top-safe area.
    * **Logical Metadata:** Dynamic player titles showing `Title (Year)` for movies and `Title (S# E#)` for series.
* **🛡️ Enhanced Stealth Ad-Blocker:** Optimized JavaScript injection to suppress the latest pop-up variants from streaming providers.
* **🏷️ Live Filtering Chips:** Added active chips for Filters and Sorting, allowing users to reset their search state with one tap.

---

## ✨ Core Features
* **Intelligent Discovery:** Explore trending content with a dynamic "Watermorphic" sliding hero section.
* **Advance Search Logic:** Multi-layered filtering by **Media Type**, **Release Year (1900–2026)**, and **Genre**.
* **⚖️ IMDb Weighted Sorting:** Sort by Latest Release, High/Low Rating, or Alphabetical Order.
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

> **Note:** Zero Stream v2.2.0 is an ongoing experiment in high-performance cross-platform UI. Feel free to fork and contribute!