# Raksha - Secure Banking App

A modern, secure Flutter banking application with comprehensive features for managing accounts, transfers, and transactions.

## 🚀 Features

### 🔐 Security & Authentication
- **Biometric Authentication**: Fingerprint and face recognition support
- **Secure Login**: Encrypted password storage and validation
- **Session Management**: Automatic token management and secure logout
- **Multiple User Profiles**: 5 different user profiles with unique banking data

### 💳 Account Management
- **Account Overview**: Real-time balance and account details
- **Multiple Accounts**: Support for savings, current, and other account types
- **Account Details**: IFSC codes, branch information, and linked cards
- **User-Specific Data**: Each user has unique account information, balances, and transaction history

### 💸 Money Transfer
- **UPI Transfers**: Quick UPI-based money transfers
- **Bank Transfers**: NEFT/IMPS transfers with account and IFSC validation
- **Contact Management**: Saved contacts for quick transfers
- **QR Code Support**: Scan QR codes for instant payments

### 📊 Transaction Management
- **Transaction History**: Complete transaction history with filtering
- **Search & Filter**: Advanced search and filter capabilities
- **Transaction Details**: Detailed view with merchant information
- **Statement Download**: PDF and CSV statement downloads
- **User-Specific Transactions**: Each user has unique transaction history

### 🎨 Modern UI/UX
- **Material Design 3**: Latest Material Design principles
- **Responsive Design**: Optimized for all screen sizes
- **Dark Mode Ready**: Theme support for different preferences
- **Accessibility**: Screen reader and accessibility support

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8+
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: Hive
- **Authentication**: Local Auth (Biometrics)
- **HTTP Client**: Dio
- **UI Components**: Material Design 3

## 📱 Screenshots

### Login Screen
- Modern gradient design
- Biometric authentication option
- Form validation and error handling

### Home Screen
- Account balance overview
- Quick action buttons
- Recent transactions preview

### Transfer Screen
- Multiple transfer options (UPI, Bank, Contact)
- Form validation
- Transfer confirmation dialogs

### Transactions Screen
- Filterable transaction list
- Search functionality
- Detailed transaction view

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/raksha.git
   cd raksha
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### User Profiles for Testing

The app includes 5 different user profiles with unique banking data for testing:

| Username | Password | Account Type | Balance | Branch | Bank |
|----------|----------|--------------|---------|--------|------|
| `deepam` | `deepam123` | Savings Account | ₹45,000 | Mumbai Main Branch | SBI |
| `pratham` | `pratham123` | Current Account | ₹32,000 | Delhi Central Branch | HDFC |
| `atharva` | `atharva123` | Savings Account | ₹78,000 | Bangalore Tech Branch | ICICI |
| `ashit` | `ashit123` | Premium Savings | ₹1,56,000 | Chennai South Branch | AXIS |
| `arijit` | `arijit123` | Savings Account | ₹92,000 | Kolkata East Branch | PNB |

Each user has:
- **Unique account details** (account number, IFSC, branch)
- **Different account balances** and types
- **Personalized transaction history** with relevant transactions
- **Custom user information** (name, email, phone)

### Platform Setup

#### Android
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: API 34 (Android 14)
- Biometric authentication requires API 23+

#### iOS
- Minimum iOS version: 12.0
- Biometric authentication requires Touch ID or Face ID

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── account.dart
│   └── transaction.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── accounts_screen.dart
│   ├── transfer_screen.dart
│   └── transactions_screen.dart
├── services/                 # Business logic
│   └── auth_service.dart
└── widgets/                  # Reusable widgets
    └── app_drawer.dart
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
API_BASE_URL=your_api_base_url
ENCRYPTION_KEY=your_encryption_key
```

### API Configuration
Update the API endpoints in the services:
- Authentication endpoints
- Account management endpoints
- Transaction endpoints

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔒 Security Features

- **Data Encryption**: All sensitive data is encrypted using AES-256
- **Secure Storage**: Credentials stored using Flutter Secure Storage
- **Network Security**: HTTPS-only API communication
- **Input Validation**: Comprehensive form validation
- **Session Management**: Automatic session timeout and logout

## 🎯 Future Enhancements

- [ ] **Push Notifications**: Real-time transaction alerts
- [ ] **Investment Management**: Mutual funds and stock trading
- [ ] **Bill Payments**: Utility bill payments and reminders
- [ ] **Budget Tracking**: Expense categorization and budgeting
- [ ] **Multi-language Support**: Internationalization
- [ ] **Offline Mode**: Basic functionality without internet
- [ ] **Voice Commands**: Voice-activated banking features
- [ ] **AI Assistant**: Chatbot for banking queries

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, email support@raksha.com or create an issue in the repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- All contributors who helped improve this project

---

**Note**: This is a demo application for educational purposes. Do not use for actual banking transactions without proper security audits and compliance checks.
