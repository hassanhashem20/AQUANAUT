# 🌍 AQUANAUT - NASA Space Apps 2025

**An Immersive Astronaut Training Experience**

[![NASA Space Apps Challenge](https://img.shields.io/badge/NASA-Space%20Apps%202025-blue.svg)](https://www.spaceappschallenge.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.3-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🚀 Project Overview

**AQUANAUT** is a cutting-edge Flutter application designed for NASA Space Apps 2025, providing an immersive astronaut training experience that combines realistic 3D Earth visualization, interactive training modules, and AI-powered assistance. This project aims to democratize space education and make astronaut training accessible to everyone.

### 🎯 Mission Statement
To create an engaging, educational platform that simulates real astronaut training experiences while fostering interest in space exploration and STEM education.

## ✨ Key Features

### 🌍 Ultra-Realistic 3D Earth Viewer
- **Google Earth Quality Graphics**: High-resolution 3D Earth with 128-segment smooth geometry
- **Realistic Landmasses**: Accurate continent shapes and positioning
- **Dynamic Ocean Colors**: Depth-based gradient coloring (polar, temperate, tropical)
- **Live ISS Tracking**: Real-time International Space Station position updates
- **Interactive Controls**: Drag to rotate, zoom in/out functionality
- **Atmospheric Effects**: Realistic atmospheric glow and cloud layers
- **5000+ Animated Stars**: Immersive space background

### 🎓 Comprehensive Training Modules
- **Suit Assembly Training**: Interactive EMU spacesuit assembly simulation
- **Pre-Breathe Protocol**: Decompression sickness prevention training
- **ISS Docking Procedures**: Space station docking alignment practice
- **ISS Onboarding Tasks**: Space station orientation and familiarization
- **Neutral Buoyancy Lab (NBL)**: Underwater training simulation
- **Mission Control Classroom**: Ground control operations training

### 🤖 AI-Powered Assistant
- **Google Gemini Integration**: Advanced AI chat powered by Gemini 1.5 Flash
- **NASA-Specific Knowledge**: Specialized space and astronaut training information
- **Real-time Assistance**: Instant help during training modules
- **Educational Support**: Detailed explanations of complex concepts

### 🎮 Gamification System
- **XP & Leveling**: Experience points and progression system
- **Achievement System**: Unlockable achievements for completed modules
- **Progress Tracking**: Detailed progress monitoring across all modules
- **Training Statistics**: Comprehensive performance analytics

### 🎨 Modern UI/UX
- **Space Theme**: Immersive dark space aesthetic with neon accents
- **Smooth Animations**: Flutter Animate powered transitions
- **Responsive Design**: Optimized for all screen sizes
- **Accessibility**: High contrast and text scaling support
- **Error Handling**: Robust error boundaries and user feedback

## 🛠️ Technical Stack

### Frontend
- **Flutter 3.24.3**: Cross-platform mobile and web development
- **Dart 3.9.2**: Modern programming language
- **Riverpod**: State management and dependency injection
- **CustomPainter**: Advanced 2D/3D graphics rendering
- **Vector Math**: 3D mathematics and transformations

### APIs & Services
- **NASA Images API**: High-quality space imagery
- **ISS Position API**: Real-time satellite tracking
- **Google Generative AI**: Advanced AI chat capabilities
- **Web Storage**: Cross-platform data persistence

### Architecture
- **Clean Architecture**: Separation of concerns and maintainability
- **Provider Pattern**: Reactive state management
- **Error Boundaries**: Graceful error handling
- **Platform Detection**: Web and mobile compatibility

## 📱 Screenshots

### 🌍 3D Earth Viewer
![Earth 3D Viewer](https://via.placeholder.com/400x300/1a1a2e/ffffff?text=3D+Earth+Viewer)

### 🎓 Training Modules
![Training Hub](https://via.placeholder.com/400x300/16213e/ffffff?text=Training+Modules)

### 🤖 AI Assistant
![AI Chat](https://via.placeholder.com/400x300/0f3460/ffffff?text=AI+Assistant)

### 📊 Progress Tracking
![Progress Dashboard](https://via.placeholder.com/400x300/533a71/ffffff?text=Progress+Tracking)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.3 or higher
- Dart SDK 3.9.2 or higher
- Web browser (Chrome, Firefox, Safari, Edge)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/aquanaut-nasa-space-apps-2025.git
   cd aquanaut-nasa-space-apps-2025
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web
   flutter run -d web-server --web-port 8080
   
   # For mobile (Android/iOS)
   flutter run --release
   ```

4. **Open in browser**
   Navigate to `http://localhost:8080`

### Configuration

1. **API Keys** (Optional)
   - Add your NASA API key to `lib/core/constants/api_keys.dart`
   - Add your Google AI API key to `lib/features/ai_chat/ai_chat_page.dart`

2. **Environment Setup**
   - Ensure Flutter web is enabled: `flutter config --enable-web`
   - For mobile development, set up Android Studio or Xcode

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and colors
│   ├── providers/          # State management
│   ├── services/           # Platform services
│   ├── widgets/            # Reusable widgets
│   └── debug/              # Debug utilities
├── features/               # Feature modules
│   ├── earth_3d/          # 3D Earth viewer
│   ├── ai_chat/           # AI assistant
│   ├── training/          # Training modules
│   └── settings/          # Settings screen
├── app/                   # App-specific modules
│   ├── steps/             # Training steps
│   └── mission_control/   # Mission control features
└── main.dart              # App entry point
```

## 🎯 NASA Space Apps 2025 Challenge

This project was developed for the **NASA Space Apps Challenge 2025**, focusing on:

### Challenge Theme: "Space for Everyone"
- **Accessibility**: Making space education accessible to all
- **Innovation**: Using cutting-edge technology for immersive learning
- **Education**: Bridging the gap between space science and public understanding
- **Inspiration**: Motivating the next generation of space explorers

### Impact Goals
- 🌍 **Global Reach**: Accessible worldwide through web technology
- 🎓 **Educational Value**: Comprehensive astronaut training simulation
- 🤝 **Community Building**: Fostering space exploration interest
- 🚀 **STEM Engagement**: Encouraging science, technology, engineering, and mathematics

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute
- 🐛 **Bug Reports**: Report issues and bugs
- 💡 **Feature Requests**: Suggest new features
- 📝 **Documentation**: Improve documentation
- 🎨 **UI/UX**: Enhance user interface
- 🔧 **Code**: Submit pull requests

### Development Guidelines
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **NASA** for inspiring space exploration and providing APIs
- **Google** for Flutter framework and Gemini AI
- **Space Apps Community** for collaboration and support
- **Open Source Contributors** for their valuable contributions

## 📞 Contact

- **Project Lead**: Hassan Hashem   
- **Email**: Hassanhashem@duck.com


## 🌟 Show Your Support

If you found this project helpful, please give it a ⭐ on GitHub!

---

**Made with ❤️ for NASA Space Apps 2025**

*"The Earth is the cradle of humanity, but mankind cannot stay in the cradle forever."* - Konstantin Tsiolkovsky

