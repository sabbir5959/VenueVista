# VenueVista - Sports Ground Booking App

A comprehensive Flutter application for sports ground booking and management.

## Features
- User registration and authentication
- Ground booking system
- Admin dashboard for management
- Venue owner dashboard
- Real-time notifications
- Payment integration

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Environment Configuration

**For Team Development:**
The project uses `.env.development` file which is shared among team members. This file contains development environment keys and is safe to commit to git.

**For Production Deployment:**
1. **Create production environment file:**
   ```bash
   cp .env.example .env.production
   ```

2. **Configure Production Supabase:**
   - Create a new project on [Supabase](https://supabase.com) for production
   - Go to Settings > API
   - Copy your Project URL and anon/public key
   - Update the `.env.production` file with production keys

**Development Setup (Team Members):**
No additional setup needed! The `.env.development` file is already configured and shared.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sabbir5959/VenueVista.git
   cd venuevista
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

**That's it!** The `.env.development` file is already configured with Supabase credentials, so your friends can start working immediately after these steps.

## Default Login Credentials

### Admin
- Phone: `01798155814`
- Password: `sabbir55`

### Owner
- Phone: `01700594133`
- Password: `owner123`

### User
- Phone: `01533985291`
- Password: `kawsar47`

## Security Notes

⚠️ **Important:** 
- The `.env.development` file is shared for team development purposes only
- **Never use development keys in production**
- Create separate `.env.production` file for production deployment
- Production environment files (`.env.production`, `.env.local`) are excluded from git

## Project Structure

```
lib/
├── admin/          # Admin dashboard and management
├── owners/         # Venue owner features
├── users/          # User-facing features
├── screens/        # Common screens
├── constants/      # App constants and colors
└── main.dart       # App entry point
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request