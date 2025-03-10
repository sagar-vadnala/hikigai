# Photo Album App

A high-performance photo album application built with Flutter that displays a large collection of images with efficient pagination, search functionality, and offline support.

## Features

- 📱 Cross-platform (Android & iOS) support
- 🖼️ Display of up to 30,000 images from Picsum Photos API
- 📄 Lazy loading implementation for smooth performance
- 🔍 Search functionality by author name or image ID
- ⚡ Offline caching for better performance
- ❤️ Favorite images with local storage
- 🌐 Network failure handling with appropriate error messages
- 🎨 Clean, modern UI using Material Design

## Screenshots

[Screenshots would go here]

## Technologies Used

- **Flutter**: UI framework for cross-platform development
- **Riverpod**: State management solution
- **Dio**: HTTP client for API requests
- **Hive**: Local database for offline caching and favorites
- **Cached Network Image**: Efficient image loading and caching
- **Connectivity Plus**: Network connectivity monitoring

## Getting Started

### Prerequisites

- Flutter (version 3.0.0 or higher)
- Dart (version 2.17.0 or higher)
- Android Studio / Xcode (for running on emulators or physical devices)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/photo-album-app.git
   ```

2. Navigate to the project directory:
   ```bash
   cd photo-album-app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/
│   └── config.dart                  # App configuration constants
├── core/
│   └── models/
│       └── networkEventResponse.dart # Network response wrapper
├── models/
│   └── photos_data.dart             # Photo data model
├── screens/
│   ├── favourites/                  # Favorites screen
│   │   ├── state/
│   │   │   └── state.dart           # Favorites state management
│   │   └── favourites_screen.dart   # Favorites UI
│   └── home/                        # Home screen
│       ├── state/
│       │   └── state.dart           # Photos state management
│       ├── widgets/
│       │   └── photo_card.dart      # Photo card component
│       └── home_screen.dart         # Main photos UI
├── services/
│   ├── api/
│   │   ├── api.dart                 # API client implementation
│   │   └── interceptors.dart        # Dio interceptors
│   └── cache/
│       └── photo_cache_service.dart # Photo caching service
├── shared/
│   ├── custom_loader.dart           # Loading indicator
│   ├── pagination/
│   │   └── pagination.dart          # Pagination implementation
│   └── widgets/
│       └── error/
│           ├── error_reload.dart    # Error widget with reload action
│           └── no_data_available.dart # Empty state widget
├── utils/
│   ├── api_utils.dart               # API helper functions
│   └── dev.log.dart                 # Logging utilities
├── widgets/
│   └── extended_cached_image.dart   # Enhanced image loading widget
└── main.dart                        # Application entry point
```

## Architecture

The application follows a clean architecture approach with the following components:

- **Models**: Data classes representing the domain entities
- **Services**: API communication, caching, and other services
- **State Management**: Riverpod for managing application state
- **UI**: Presentation layer with screens and widgets

## API Integration

The app integrates with the [Picsum Photos API](https://picsum.photos/) to fetch sample images. The implementation includes:

- Pagination support for efficient loading
- Error handling for network failures
- Response parsing and mapping to domain models

## Offline Support

The application implements offline support through:

1. **Image Caching**: Images are cached using CachedNetworkImage
2. **Data Persistence**: Photo metadata is stored using Hive
3. **Connectivity Detection**: The app detects network status and adapts accordingly
4. **Offline Indicator**: Users are informed when viewing cached content

## Performance Optimization

To ensure smooth performance with up to 30,000 images, the app implements:

- **Lazy Loading**: Only loads images as needed when scrolling
- **Efficient List Rendering**: Using SliverGrid for optimized list rendering
- **Image Caching**: Preventing unnecessary network requests
- **Memory Management**: Proper handling of large collections

## Future Improvements

- Implement image detail view with zooming capabilities
- Add custom collections/albums feature
- Implement advanced filtering options
- Add image sharing functionality
- Enhance UI with animations and transitions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Picsum Photos](https://picsum.photos/) for providing the image API
- [Flutter](https://flutter.dev/) and the Flutter team for the amazing framework
- All the package authors that made this project possible