# BEACON: online and offline learning

BEACON contains two installed applications backed by one Supabase project:

- The existing Flutter student app, including its aquatic UI, eight sessions, concepts, simulations, games, quizzes, profile, progress, settings, audio, and image assets.
- A React Native for Windows teacher app with sign-in, classes, students, lessons, quizzes, synchronized results, progress, reports, and settings. The React Native project also retains its Android target for future builds.

Both applications keep supported offline data in a real SQLite `.db` file. They explicitly synchronize through a retryable outbox when connected; a SQLite file is never treated as if it automatically synchronizes with PostgreSQL.

## Repository map

```text
physics_of_fluids/
|-- lib/                         Flutter student app
|   |-- screens/                 Existing student UI and navigation
|   |-- services/                App state, SQLite, audio, Supabase sync
|   `-- widgets/                 Shared UI and sync-status control
|-- assets/                      Existing student images, video, and audio
|-- sqlite/                      Packaged profile/session SQLite templates
|-- teacher_app/                 React Native + React Native for Windows app
|   |-- src/data/                Teacher SQLite database and repositories
|   |-- src/services/            Supabase and bidirectional sync
|   |-- windows/                 Installed Windows application project
|   |-- android/                 Android target retained for expansion
|   `-- __tests__/               Conflict/sync policy tests
|-- supabase/
|   |-- migrations/              Reproducible schema, indexes, RPC, and RLS
|   `-- seed.sql                 Clearly labeled sample content
|-- docs/ARCHITECTURE.md         Data flow, security, and conflict rules
|-- docs/SETUP.md                VS Code, Flutter, Windows, and Supabase setup
`-- docs/IMPLEMENTATION_STATUS.md Exact verification and remaining setup
```

## Quick verification

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug

cd teacher_app
npm install
npm run typecheck
npm test -- --runInBand
npm run lint
npm run windows -- --no-launch --no-packager
```

The Windows build requires Windows Developer Mode to deploy the package. Building and deploying are separate: the native solution can compile successfully even when deployment is blocked by Developer Mode.

See [setup instructions](docs/SETUP.md), the [architecture and sync contract](docs/ARCHITECTURE.md), and the [verified implementation status](docs/IMPLEMENTATION_STATUS.md) before connecting a real Supabase project.

## Content status

The existing Flutter lessons and activities are preserved. Teacher dashboard records and Supabase seed rows are explicitly labeled sample content so the system can be exercised before real class data is supplied. Replace them with the school's final Grade 11 lesson text, assessment questions, class roster, and marking rules before production use.
