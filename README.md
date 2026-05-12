# 🎬 Zero Stream

[![Flutter Version](https://img.shields.io/badge/Flutter-3.11.4-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-1.2.0-green.svg)](https://github.com/hyper-crazy/zero_cost_streamer/releases)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-lightgrey.svg)](#)

**Zero Stream** is a high-performance, modern streaming application built with Flutter. It combines the massive metadata library of **TMDB** with a seamless viewing experience, all wrapped in a "Watermorphic" frosted-glass UI.

---

## 🚀 What's New in v1.2.0 (The Branding & Polish Update)
In this release, I've focused on professional-grade branding and refinement:

* **🎨 Adaptive Launcher Icons:** Re-scaled the app branding to 42% for perfect fitment within Android's adaptive "Safe Zone."
* **✨ Custom Splash Screen:** Implemented a clean, white-themed splash screen with the core logo centered for a premium loading experience.
* **📡 Connectivity Guard:** Smart real-time network monitoring with auto-refresh logic when back online.
* **📦 Custom APK Naming:** Automated Gradle scripts to generate builds named `Zero_Stream v1.2.0.apk` for better version tracking.

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
| <img src="assets/images/Home%20Screen.jpg" width="200" alt="Home Screen" /> | <img src="assets/images/Content%20Details.jpg" width="200" alt="Content Details" /> | <img src="assets/images/Episode%20Selection.jpg" width="200" alt="Episode Selection" /> |

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