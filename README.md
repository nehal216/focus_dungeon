# Focus Dungeon

### An RPG Productivity App

> **Turn your focus sessions into dungeon runs. Defeat distractions. Earn XP. Level up.**

Focus Dungeon is a gamified productivity and focus-tracking mobile application built with **Flutter** and **Firebase**.

Instead of treating productivity as another boring timer, Focus Dungeon turns focused work sessions into RPG-style dungeon runs. Users select a dungeon, start a focus session, and earn **XP and Coins** when they successfully complete it.

The goal is simple:

**Focus in the real world → Progress in the game.**

---

## Features

### User Authentication

* User registration with email and password
* Secure login using Firebase Authentication
* Password reset functionality
* Logout confirmation
* Account deletion
* Firebase-based user identity management

### Dungeon Focus Sessions

Users can choose from different dungeon difficulties and turn their focus time into a game session.

| Dungeon           |  Duration |   XP Reward | Coin Reward |
| ----------------- | --------: | ----------: | ----------: |
| Easy Dungeon   |  1 minute |       10 XP |     5 Coins |
| Medium Dungeon | 3 minutes |       25 XP |    15 Coins |
| Hard Dungeon   | 5 minutes |       50 XP |    30 Coins |
| Custom Dungeon |    Custom | 2 × minutes |  1 × minute |

The timer supports:

* Start
* Pause
* Resume
* Stop
* Completion detection
* Session completion rewards
* Confirmation before abandoning an active session

### XP & Level System

Successful focus sessions reward users with XP.

When the accumulated XP reaches the current level's threshold:

```text
Required XP = Current Level × 50
```

the user's level increases and excess XP is carried forward.

### Coin Rewards

Completed dungeon sessions reward Coins based on the selected dungeon.

Coins are stored in Firestore and can be used as the foundation for future in-game reward and customization systems.

### Player Profile

The profile screen allows users to:

* View their email
* Set and edit their username
* Set and edit their phone number
* Permanently delete their account

Email is read-only because it is linked to the Firebase Authentication account.

### Player Statistics

The Stats screen displays:

* Current Level
* XP
* Coins
* Total Focus Time
* Total Sessions Completed

This provides users with a simple overview of their productivity progress.

### Pixel-Art Inspired UI

The application uses a retro RPG-inspired interface featuring:

* Pixel-style typography
* VT323 font
* Purple dungeon-themed color palette
* Sharp rectangular borders
* RPG-style terminology
* Game-inspired buttons and dialogs

---

## Tech Stack

| Technology                   | Purpose                                       |
| ---------------------------- | --------------------------------------------- |
| **Flutter**                  | Cross-platform mobile application development |
| **Dart**                     | Application programming language              |
| **Firebase Authentication**  | User registration, login and password reset   |
| **Cloud Firestore**          | User profiles and productivity statistics     |
| **Git**                      | Version control                               |
| **GitHub**                   | Source code hosting                           |
| **Android Studio / VS Code** | Development and debugging                     |
| **Figma / Canva**            | UI/UX design and prototyping                  |

The project uses Flutter for the frontend and Firebase services for authentication and cloud data storage.

---

## Project Architecture

Focus Dungeon follows a modular screen-based architecture.

```text
Focus Dungeon
│
├── Authentication
│   ├── Login Screen
│   └── Sign Up Screen
│
├── Main Application
│   └── Home Screen
│
├── Focus System
│   └── Dungeon Screen
│
├── Player Management
│   ├── Profile Screen
│   └── Stats Screen
│
├── Services
│   ├── Auth Service
│   └── Firestore Service
│
└── Firebase
    ├── Firebase Authentication
    └── Cloud Firestore
```

Each major screen is separated into its own Dart file, keeping the application modular and easier to maintain.

---

## Application Flow

```text
                    ┌──────────────┐
                    │    LOGIN     │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │     HOME     │
                    └──────┬───────┘
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
        DUNGEON         PROFILE        STATS
             │
             ▼
       START SESSION
             │
             ▼
       FOCUS TIMER
             │
       ┌─────┴─────┐
       │           │
    COMPLETE     STOP
       │           │
       ▼           ▼
   XP + COINS    EXIT
       │
       ▼
   LEVEL UPDATE
       │
       ▼
      HOME
```

---

## Firebase Integration

Focus Dungeon uses **Firebase Authentication** for managing user accounts and **Cloud Firestore** for persistent user data.

Each authenticated user has a document in the:

```text
users
```

collection.

The document is identified using the user's Firebase UID.

### User Data Structure

```text
users
│
└── {user_uid}
    ├── email
    ├── username
    ├── phone
    ├── level
    ├── xp
    ├── coins
    ├── streak
    ├── totalFocusTime
    ├── totalSessions
    └── createdAt
```

The application initializes these values when a new account is created.

---

## Focus Timer

The dungeon timer is implemented using Dart's `Timer.periodic()`.

The timer updates once every second:

```dart
timer = Timer.periodic(
  const Duration(seconds: 1),
  (t) {
    if (!isPaused) {
      if (secondsLeft == 0) {
        t.cancel();
        completeDungeon();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    }
  },
);
```

The timer also supports pausing and resuming without resetting the remaining time.

The timer is cancelled inside `dispose()` to prevent unnecessary background activity and memory leaks.

---

## Atomic Reward Updates

Dungeon rewards are updated using a **Cloud Firestore transaction**.

This ensures that XP, level, Coins, total focus time, and completed sessions are updated consistently.

```dart
await FirebaseFirestore.instance.runTransaction(
  (transaction) async {
    final snapshot = await transaction.get(docRef);

    int currentXp = snapshot['xp'];
    int currentLevel = snapshot['level'];
    int currentCoins = snapshot['coins'];

    int newXp = currentXp + widget.xpReward;
    int requiredXp = currentLevel * 50;

    if (newXp >= requiredXp) {
      newXp -= requiredXp;
      currentLevel++;
    }

    transaction.update(docRef, {
      'xp': newXp,
      'level': currentLevel,
      'coins': currentCoins + widget.coinReward,
      'totalFocusTime':
          FieldValue.increment(widget.duration ~/ 60),
      'totalSessions':
          FieldValue.increment(1),
    });
  },
);
```

This approach helps maintain data consistency when updating multiple user statistics.

---

## Main Screens

### Login Screen

Provides:

* Email input
* Password input
* Password visibility toggle
* Login
* Forgot password
* Sign-up navigation

### Sign Up Screen

Allows new users to:

* Enter their email
* Create a password
* Create a Firebase Authentication account
* Initialize their Firestore player profile

### Home Screen

The main dashboard displays:

* Player username
* Coins
* XP
* Level
* Easy Dungeon
* Medium Dungeon
* Hard Dungeon
* Custom Dungeon
* Profile
* Statistics
* Logout

### Dungeon Screen

Handles the core productivity mechanic:

* Countdown timer
* Start session
* Pause
* Resume
* Stop
* Completion rewards
* XP and level progression

### Profile Screen

Provides:

* Email display
* Username editing
* Phone number editing
* Account deletion

### Stats Screen

Displays:

* Level
* XP
* Coins
* Total focus time
* Completed sessions

---

## Testing

The project was tested using multiple testing approaches:

* **Black Box Testing**
* **White Box Testing**
* **Functional Testing**
* **Unit Testing**
* **Integration Testing**
* **User Acceptance Testing (UAT)**
* **Beta Testing**

The project report documents **12 functional test cases**, covering authentication, dungeon sessions, pausing/resuming, stopping sessions, level progression, custom sessions, profile editing, password reset, and account deletion.

---

## Getting Started

### Prerequisites

Before running the project, install:

* Flutter SDK
* Dart SDK
* Android Studio or Visual Studio Code
* Android SDK
* JDK
* A Firebase project
* Git

You can verify your Flutter installation using:

```bash
flutter doctor
```

---

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/focus-dungeon.git
```

Navigate into the project:

```bash
cd focus-dungeon
```

---

### 2. Install Dependencies

Run:

```bash
flutter pub get
```

---

### 3. Configure Firebase

Create a Firebase project and connect it to the Flutter application.

Enable:

* Firebase Authentication
* Email/Password Authentication
* Cloud Firestore

Make sure the appropriate Firebase configuration files are added to the project.

**Do not commit private credentials, secrets, or unnecessary Firebase configuration containing sensitive information to a public repository.**

---

### 4. Run the Application

Connect an Android device or start an emulator and run:

```bash
flutter run
```

---

## Security Considerations

Because the application stores user accounts and productivity data, security is an important part of the system.

The project considers:

* Firebase Authentication
* Firestore Security Rules
* Protected user data
* Transaction-based reward updates
* Account deletion
* Authentication session management

The project also identifies potential future security concerns such as client-side manipulation, reward cheating, unauthorized database access, bot accounts, and API/cloud access vulnerabilities.

---

## Development Model

Focus Dungeon was developed using an **Iterative and Incremental Development Model**.

The application was divided into smaller components that could be developed, tested, and improved independently.

The development process focused on:

```text
UI/UX Design
     ↓
Authentication
     ↓
Focus Engine
     ↓
Dungeon System
     ↓
Reward System
     ↓
Statistics
     ↓
Testing & Refinement
```

This approach allowed individual features to be implemented and tested before integrating them into the complete application.

---

## Future Scope

Focus Dungeon can be expanded considerably in future versions.

Possible improvements include:

### Advanced RPG Mechanics

* Multiple dungeon levels
* Boss battles
* Unlockable characters
* New enemy types
* Achievements
* Loot systems
* Cosmetic items
* Character progression

### Advanced Analytics

* Weekly productivity reports
* Monthly productivity reports
* Focus graphs
* Productivity trends
* Personalized insights

### Social Features

* Friend leaderboards
* Study groups
* Shared focus challenges
* Guilds
* Cooperative dungeon runs

### Smart Productivity

* AI-powered productivity suggestions
* Smart scheduling
* Personalized focus recommendations
* Adaptive session difficulty

### Additional Features

* Offline focus sessions
* Automatic cloud synchronization
* Push notifications
* Reminders
* Dark mode customization
* Sound and background music
* Personalized themes
* Wearable device integration
* AR-based gameplay

These enhancements could evolve Focus Dungeon from a basic gamified timer into a more complete RPG productivity platform.

---

## Screenshots

Add your application screenshots here once you upload them to the repository.

Example:

```markdown
## Screenshots

### Login
![Login Screen](screenshots/login.png)

### Home
![Home Screen](screenshots/home.png)

### Dungeon
![Dungeon Screen](screenshots/dungeon.png)

### Player Profile
![Profile Screen](screenshots/profile.png)

### Player Stats
![Stats Screen](screenshots/stats.png)
```

A good GitHub README without screenshots is like an RPG character with no armor: technically functional, but needlessly disappointing.

---

## Project Documentation

The complete academic project report contains detailed information about:

* Introduction and objectives
* System analysis
* Requirements
* System design
* Architecture
* Implementation
* Testing
* Results
* Security considerations
* Conclusions
* Future scope

The project was developed as a **Bachelor of Science in Information Technology** project under the Department of Information Technology at JES College of Commerce, Science and Information Technology, affiliated with the University of Mumbai.

---

## Author

**Nehal Santosh Anbhavne**

Bachelor of Science in Information Technology

JES College of Commerce, Science and Information Technology
University of Mumbai

---

## License

This project was developed as an academic project.

If you intend to reuse, modify, or distribute the source code, please add an appropriate license to this repository.

---

## ⭐ Support

If you find the project interesting, consider giving the repository a ⭐ on GitHub.

Every star apparently makes the code work 3% better. This is not scientifically established, but GitHub culture demands we pretend.
