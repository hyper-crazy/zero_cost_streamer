# 🎬 Zero Stream

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-1.1.0-green.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming application built with Flutter. It combines the massive metadata library of **TMDB** with a seamless viewing experience, all wrapped in a "Watermorphic" frosted-glass UI.

---

## 🚀 What's New in v1.1.0 (The Connectivity Update)
In this minor release, I've focused on making the app "bulletproof" against network fluctuations and refining the user interface for premium devices:

* **📡 Smart Connectivity Monitoring:** Integrated real-time network listeners. The app now detects when you're offline, notifies you instantly via custom SnackBars, and auto-refreshes data the moment you're back online.
* **🛠 UI Persistence Fix:** Re-engineered the **Season Selection Screen** using dynamic `MediaQuery` logic. This ensures the bottom season picker stays perfectly positioned above the system navigation bar, even on high-res devices like the **S24 Ultra**.
* **⚖️ Official Attribution:** Integrated TMDB attribution across the app's details screens to maintain legal compliance while keeping the design clean.
* **🔒 Stable Player Environment:** Restored the core WebView player logic to ensure maximum compatibility and prevent SSL/Handshake errors across different streaming servers.

---

## ✨ Core Features
* **Live Content Search:** Instant search results with real-time API fetching.
* **Dual-Tone Themes:** Supports a crisp **Coffee Cream** Light Mode and a deep **TMDB Navy** Dark Mode.
* **Advanced Series Management:** Detailed season and episode lists with dynamic background blurs.
* **Resource Efficient:** Optimized image caching and lazy-loading for low data consumption.

---

## 📸 Screenshots

| Home Screen | Content Details | Episode Selection |
| :---: | :---: | :---: |
| <img src="assets/images/home_screen.png" width="200" /> | <img src="assets/images/content_details.png" width="200" /> | <img src="assets/images/episode_selection.png" width="200" /> |

---

## ⚙️ Setup & Installation
1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/hyper-crazy/zero_cost_streamer.git](https://github.com/hyper-crazy/zero_cost_streamer.git)
    ```
2.  **Environment Configuration:** Create a `.env` file in the root directory:
    ```env
    TMDB_API_KEY=your_api_key_here
    ```
3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Build the Release APK:**
    ```bash
    flutter build apk --release
    ```

---

## 🛠 Tech Stack
* **Framework:** Flutter
* **State Management:** Provider
* **Networking:** HTTP & Connectivity Plus
* **UI Assets:** Google Fonts, Flutter SVG, Cached Network Image
* **Rendering:** Material 3 with custom Glassmorphism layers

---

## 📜 Attribution & Legal
* This app uses the TMDB API but is not endorsed or certified by TMDB.
* Streaming content is provided by third-party providers (VidSrc). The app does not host any media files.

---

## 👨‍💻 Developed By
**Morshedul Islam Maruf** *Lead Developer* GitHub: [@hyper-crazy](https://github.com/hyper-crazy)

---

> **Note:** This project was developed as part of a high-performance streaming experiment. Feel free to contribute or report bugs!