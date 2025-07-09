# VenueVista

A Flutter application for booking football grounds and turfs easily.

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/                     # All screen widgets
│   ├── landing_page.dart        # Splash/Landing screen
│   ├── login_page.dart          # User login screen
│   └── dashboard_page.dart      # Main dashboard
├── widgets/                     # Reusable widgets
│   └── app_logo.dart           # App logo widget
└── utils/                      # Utility functions and constants
```

## Features

- ✅ Animated landing page
- ✅ User login interface
- ✅ Dashboard with ground listings
- ✅ Responsive design
- ✅ Material 3 design system

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Design Highlights

### Dashboard Features:
- **Top-right logo**: VenueVista brand logo
- **Left sidebar menu**: Navigation drawer with user options
- **Choose Ground section**: Prominent header for ground selection
- **Scrollable ground list**: Cards showing ground details with images, names, ratings, and prices
- **Search functionality**: Find specific grounds easily

### Color Scheme:
- Primary: Green (#4CAF50)
- Background: Light grey (#FAFAFA)
- Cards: White with subtle shadows

## TODO

- [ ] Add ground details page
- [ ] Implement booking functionality
- [ ] Add user authentication
- [ ] Add favorites feature
- [ ] Add filters and sorting
- [ ] Add payment integration
