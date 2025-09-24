# InclusIA  

InclusIA is a cross-platform application (Android, iOS, Web) developed with **Flutter** and **Firebase**.  
It was created during my internship at **SIC4Change** with the goal of analyzing and correcting text using **Google’s Gemini AI** through Firebase extensions.  


## 🚀 Features  
- Developed using **JavaScript** (Firebase Cloud Functions) and **Dart** (Flutter frontend).  
- Upload text directly from the app or select files (`.txt`, `.pdf`).  
- Store uploaded files in **Firebase Storage**.  
- Automatically extract and process text from uploaded documents (including PDF parsing).  
- Cloud Functions:  
  - **User management**: add user ID and creation date when a new user is created in Firestore.  
  - **File processing**: extract text from uploaded `.txt` and `.pdf` files, then save them in the `processedFiles` collection.  
- AI-based text analysis and correction using **Gemini**.  
- Real-time updates with **Riverpod** state management.  
- Cross-platform compatibility: **Android, iOS, Web**.  


## 📂 Project Structure  
```
InclusIA/
│── README.md
│── firebase.json
│── firestore.indexes.json
│── firestore.rules                 # Firestore rules (restricted)
│── storage.rules # Storage rules
│
├── functions/                      # Firebase backend (Cloud Functions)
│ ├── index.js                      # Functions for user creation & file processing
│ └── package.json
│
└── app_flutter/                    # Flutter frontend app
├── pubspec.yaml
├── analysis_options.yaml
└── lib/
├── main.dart
├── home_page.dart
├── firebase_options.dart           # Firebase config (API keys censored)
└── providers/
└── upload_notifier.dart
```


## 🛠️ Requirements  
- **Node.js** 18+  
- **Firebase CLI**  
- **Flutter SDK** 3.x  
- Dart 3.x  


## 🔧 Setup & Deployment  

### Backend (Cloud Functions)  
1. Navigate to `functions/`  
2. Install dependencies:  
   ```bash
   npm install
   ```
3. Deploy to Firebase:
   ```bash
   firebase deploy --only functions
   ```

### Firestore & Storage Rules
Deploy security rules:
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### Frontend (Flutter App)
1. Navigate to app_flutter/
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run locally:
   ```bash
   flutter run
   ```


## 🔒 Security Notes
- All Firebase credentials in firebase_options.dart are censored with placeholders (e.g., YOUR_API_KEY).
- Update them with your own Firebase project credentials generated via the FlutterFire CLI.


## 📖 About
- InclusIA was developed during my internship at SIC4Change.
- It combines Flutter for the frontend, Firebase for backend services (Firestore, Storage, Cloud Functions), and Gemini AI for analyzing and correcting texts to promote inclusive language.
