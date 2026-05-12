# 🎬 Zero Stream - Pre-Release v2.0.0

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-2.0.0-orange.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming platform. The v2.0.0 update marks a complete overhaul of the search engine, UI stability, and filtering capabilities, making it one of the most powerful TMDB-based clients.

---

## 🚀 What's New in v2.0.0 (The Power-User Update)
In this major version, we've shifted from a basic browser to a full-fledged content discovery engine:

* **🔍 Advance Search Engine:** A dedicated search suite allowing users to filter content by **Media Type (All/Movies/TV)**, **Release Year (1900–2026)**, and **Multi-Genre selection**.
* **⚖️ IMDb Weighted Sorting:** Real-time sorting logic via a Floating Action Button. Sort results by **Latest Release**, **Rating (High to Low)**, or **Alphabetical Order**.
* **🎨 Uniform Branding:** * Fixed the "Invisible Logo" bug in Light Mode.
    * Stabilized Splash Screen background to `#E6E0D4` across all system themes.
* **⚡ State Preservation:** Improved `uiMode` configurations in Android Manifest to prevent app restarts during system theme switching.
* **💎 UI Refinement:** Integrated the Advance Search button directly into a premium-styled container within the search bar.

---

## ✨ Core Features
* **Intelligent Discovery:** Explore trending content with a dynamic "Watermorphic" sliding hero section.
* **Dual-Tone Experience:** High-contrast **TMDB Navy** for night owls and **Coffee Cream** for a premium light aesthetic.
* **Advanced Filtering:** Find exactly what you want with a date range spanning over a century of cinema.
* **Performance First:** Zero-lag UI transitions using optimized Provider state management and lazy-loaded image caching.

---

## 📸 Screenshots

| Home Screen | Advance Search | Episode Selection |
| :---: | :---: | :---: |
| <img src="assets/images/Home%20Screen.jpg" width="200" alt="Home Screen" /> | <img src="assets/images/image_9c104e.png" width="200" alt="Advance Search" /> | <img src="assets/images/Episode%20Selection.jpg" width="200" alt="Episode Selection" /> |

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
3.  **Generate Splash Screens:**
    ```bash
    flutter pub get
    dart run flutter_native_splash:create
    ```
4.  **Build & Run:**
    ```bash
    flutter build apk --release
    ```

---

## 🛠 Tech Stack
* **Framework:** Flutter (Material 3)
* **State Management:** Provider
* **Networking:** HTTP & Connectivity Plus
* **Branding:** Flutter Native Splash & Flutter Launcher Icons
* **Fonts:** Google Fonts (Montserrat)

---

## 📜 Attribution & Legal
* This app uses the TMDB API but is not endorsed or certified by TMDB.
* Zero Stream is an aggregator. It does not host media; it provides a seamless interface to access publicly available metadata and third-party streaming links.

---

## 👨‍💻 Developed By
**Morshedul Islam Maruf** *Lead Developer* GitHub: [@hyper-crazy](https://github.com/hyper-crazy)

---

> **Note:** Zero Stream v2.0.0 is part of an ongoing experiment in high-performance Flutter UI. Feel free to fork and contribute!