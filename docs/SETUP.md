# BEACON setup in VS Code

## 1. Flutter student app

Install Flutter with Android tooling, open the repository root in VS Code, then run:

```powershell
flutter doctor
flutter pub get
flutter run -d android `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Without those two defines, the complete existing offline student experience still runs and the sync indicator reports local-only mode. Do not pass a service-role key.

## 2. Supabase

Create a Supabase project, install the Supabase CLI, and authenticate it. From this repository:

```powershell
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase db seed
```

`supabase db push` applies `supabase/migrations/202610300001_beacon_core.sql`. The optional seed contains sample records only. Create users in Supabase Auth, then create matching `profiles` rows with role `student` or `teacher`. Assign teachers through `class_teachers` and students through `class_enrollments` before expecting RLS-protected data to appear.

## 3. Teacher Windows app

Requirements:

- Node.js 22.11 or newer;
- Visual Studio with Desktop development with C++, Universal Windows Platform tools, Windows App SDK/C++ workload, and Windows SDK 10.0.22621 or newer;
- Windows Developer Mode for deployment;
- React Native for Windows prerequisites.

Open `teacher_app/src/config.ts` and set only the public Supabase URL and anon key. Then:

```powershell
cd teacher_app
npm install
npm start
```

In a second terminal:

```powershell
cd teacher_app
npm run windows
```

The checked-in patch files retarget two third-party Windows projects to the Visual Studio 2026 toolset installed on this development machine. On Visual Studio 2022, either install the v143 workload or adjust/remove those two toolset patches to match the machine.

The application creates `beacon_teacher.db` in the Windows document directory. The selected `react-native-turbo-sqlite` dependency has native Windows and Android projects and is autolinked in both targets.

## 4. Teacher Android extension

The React Native project retains `teacher_app/android`. With Android Studio/SDK configured, run:

```powershell
cd teacher_app
npm run android
```

On Android the same database is created in the app-private files directory. If the checkout path is long, Windows native Android builds can hit Ninja's 260-character object-path limit. A temporary short drive mapping avoids that without moving the repository:

```powershell
$teacherPath = (Resolve-Path .).Path
subst R: $teacherPath
R:\android\gradlew.bat -p R:\android assembleDebug
subst R: /D
```

Windows is the delivered teacher target. The Android debug APK compiles, but Android UI/device validation remains a deployment step.

## 5. Verification and troubleshooting

```powershell
# Student
flutter analyze
flutter test
flutter build apk --debug

# Teacher
cd teacher_app
npm run typecheck
npm test -- --runInBand
npm run lint
npm run windows -- --no-launch --no-packager
```

If the Windows command compiles but fails at `Enabling Developer Mode`, enable **Settings > System > For developers > Developer Mode**, then rerun. Supabase integration tests need a configured project and valid teacher/student accounts; unit tests intentionally do not contain credentials.
