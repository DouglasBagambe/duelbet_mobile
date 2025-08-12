# DuelBet Mobile - Player Search System

## 🎯 Overview

This is the mobile version of DuelBet, a Solana-based 1v1 wagering app where users bet against each other on Lichess chess games and soccer matches. The player search system allows users to find and challenge other players on Lichess.

## 🏗️ Architecture

### Frontend (Flutter) ✅ **WORKING**

- **PlayerSearchScreen**: Main screen for searching Lichess players
- **LichessService**: Service for making API calls to Lichess (with rate limiting)
- **LichessPlayer**: Model class for player data
- **Integration**: Connected to the main app via the LICHESS DUEL card

### Backend (Dart) ⚠️ **OPTIONAL**

- **LichessBackendService**: Backend service with rate limiting and caching
- **Server**: HTTP server with REST API endpoints
- **Note**: The frontend works independently without the backend

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+

## 🚀 Quick Start (Frontend Only)

1. **Clone and navigate:**

   ```bash
   cd duelbet_mobile/frontend
   ```

2. **Get dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the app:**

   ```bash
   flutter run
   ```

4. **Test player search:**
   - Tap "LICHESS DUEL" card
   - Search for "DrNykterstein" or "Hikaru"
   - See the player search in action!

### Frontend Setup

1. **Navigate to the frontend directory:**

   ```bash
   cd duelbet_mobile/frontend
   ```

2. **Get dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Backend Setup

1. **Navigate to the backend directory:**

   ```bash
   cd duelbet_mobile/backend
   ```

2. **Get dependencies:**

   ```bash
   dart pub get
   ```

3. **Run the server:**
   ```bash
   dart run bin/server.dart
   ```

The backend server will start on `http://localhost:3001`

## 🚨 Current Status

### ✅ **Working Features**

- Player search functionality
- Lichess API integration
- Beautiful UI with animations
- Error handling and user feedback
- Rate limiting and timeouts
- Integration with main app

### ⚠️ **Backend Issues**

- Dependency resolution problems with shelf packages
- Not required for frontend functionality
- Can be fixed later if needed

### 🔄 **Next Steps**

1. Test the frontend player search
2. Create challenges with selected players
3. Integrate Solana wallet functionality
4. Add more game types and features

## 🔍 Player Search Features

### Search Functionality ✅

- **Real-time search**: Search for Lichess players by username
- **Player information**: Display player stats, ratings, and online status
- **Rate limiting**: Built-in rate limiting (1 second between requests)
- **Error handling**: Graceful handling of network errors and invalid users

### Player Data Display

- **Basic info**: Username, title, online status
- **Game statistics**: Total games, win rate, ratings
- **Performance data**: Ratings for different game types (Blitz, Rapid, Bullet)
- **Activity status**: Currently playing, online, or offline

### UI Features

- **Smooth animations**: Fade and slide transitions
- **Haptic feedback**: Tactile responses for user interactions
- **Dark theme**: Consistent with the app's design
- **Responsive design**: Works on different screen sizes

## 📱 How to Use

### 1. Access Player Search

- From the home screen, tap on the **"LICHESS DUEL"** card
- This will open the Player Search screen

### 2. Search for a Player

- Enter a Lichess username in the search field
- Tap the search button or press Enter
- The app will fetch player information from Lichess

### 3. View Player Details

- Player information will be displayed below the search
- See player stats, ratings, and current status
- Select a player to continue with challenge creation

### 4. Continue with Selected Player

- Tap "Continue with Selected Player" to proceed
- The selected player data will be returned to the previous screen

## 🔌 API Endpoints

### Backend Server Endpoints

#### Health Check

```
GET /health
```

#### Lichess User Info

```
GET /api/lichess/user/{username}
```

#### Lichess User Games

```
GET /api/lichess/games/{username}?max=10&rated=true
```

#### Lichess User Performance

```
GET /api/lichess/perf/{username}/{perf}
```

#### Search Users

```
GET /api/lichess/search?q={query}
```

#### Cache Management

```
GET /api/cache/stats
GET /api/cache/rate-limit
DELETE /api/cache/user/{username}
DELETE /api/cache/all
```

## 🏗️ Code Structure

```
duelbet_mobile/
├── frontend/
│   ├── lib/
│   │   ├── screens/
│   │   │   └── player_search_screen.dart
│   │   ├── services/
│   │   │   └── lichess_service.dart
│   │   ├── models/
│   │   │   └── lichess_player.dart
│   │   └── main.dart
│   └── pubspec.yaml
└── backend/
    ├── lib/
    │   └── lichess_backend_service.dart
    ├── bin/
    │   └── server.dart
    └── pubspec.yaml
```

## 🔧 Configuration

### Rate Limiting

The backend service includes rate limiting to respect Lichess API limits:

- **Max requests per minute**: 60
- **Cache expiry**: 5 minutes
- **Request timeout**: 10 seconds

### Caching

- **User data**: Cached for 5 minutes
- **Automatic cleanup**: Old cache entries are automatically removed
- **Manual management**: Cache can be cleared via API endpoints

## 🚨 Error Handling

### Network Errors

- Connection timeouts
- Network unreachable
- Invalid responses

### API Errors

- User not found
- Rate limit exceeded
- Invalid requests

### User Feedback

- Error messages displayed in the UI
- Success notifications for successful operations
- Loading states during API calls

## 🔒 Security Features

- **Rate limiting**: Prevents API abuse
- **Input validation**: Sanitizes user inputs
- **Error masking**: Doesn't expose sensitive information
- **CORS support**: Configurable cross-origin requests

## 🧪 Testing

### Frontend Testing

```bash
cd duelbet_mobile/frontend
flutter test
```

### Backend Testing

```bash
cd duelbet_mobile/backend
dart test
```

## 📈 Performance

### Optimization Features

- **Lazy loading**: Data loaded only when needed
- **Caching**: Reduces API calls and improves response times
- **Rate limiting**: Prevents overwhelming external APIs
- **Async operations**: Non-blocking UI during API calls

### Monitoring

- **Cache statistics**: Track cache hit rates
- **Rate limit status**: Monitor API usage
- **Request history**: Track API call patterns

## 🚀 Future Enhancements

### Planned Features

- **Offline support**: Cache data for offline viewing
- **Push notifications**: Notify when players come online
- **Advanced filtering**: Filter by rating, game type, etc.
- **Player comparison**: Compare multiple players
- **Favorites**: Save frequently searched players

### Technical Improvements

- **WebSocket support**: Real-time player status updates
- **Background sync**: Periodic data updates
- **Analytics**: Track user search patterns
- **A/B testing**: Test different UI variations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

- Create an issue in the repository
- Check the documentation
- Review the code examples

## 🔗 Related Links

- **DuelBet Web App**: The original web version
- **Lichess API**: Official Lichess API documentation
- **Solana**: Blockchain platform for smart contracts
- **Flutter**: UI framework for mobile development
