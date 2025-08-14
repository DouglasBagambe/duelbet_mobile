// Program IDs
const String PROGRAM_ID = "6tji6PU7Mw2jQ9p7okEi88M8Boannre5nND5mAmjB3i6";

// Token Configuration
// This is a test token on devnet. Replace with your actual token mint address in production
const String WAGER_TOKEN_MINT = "So11111111111111111111111111111111111111112"; // Using SOL as a test token

// API Configuration
const String LICHESS_API_URL = "https://lichess.org/api";
const String LICHESS_WS_URL = "wss://socket.lichess.org";

// Game Configuration
const Map<String, dynamic> DEFAULT_TIME_CONTROL = {
  "initialTime": 600, // 10 minutes in seconds
  "increment": 0,
  "variant": "standard",
};

const List<String> GAME_VARIANTS = [
  "standard",
  "chess960",
  "crazyhouse",
  "antichess",
  "atomic",
  "horde",
  "kingOfTheHill",
  "racingKings",
  "threeCheck",
];

// Solana Configuration
const String RPC_ENDPOINT = "https://api.devnet.solana.com";
const String COMMITMENT = "confirmed";
