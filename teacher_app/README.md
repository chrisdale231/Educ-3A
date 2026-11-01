# BEACON Teacher

Installed React Native for Windows application for teachers. It provides Supabase Auth sign-in, class/student lists, lesson and quiz publication management, synchronized results, student progress, basic reports, and offline status/error visibility.

The app stores its working cache and outbox in `beacon_teacher.db` using `react-native-turbo-sqlite`. Pending changes are retried without discarding unsynchronized work. Windows uses the document directory; Android uses its app-private files directory.

## Configure

The public Supabase project URL and publishable key are configured in
`src/config.ts`. A publishable key is a client identifier; Row Level Security
protects the data. Never add the service-role key to this application.

## Run

```powershell
npm install
npm start
```

In another terminal:

```powershell
npm run windows
```

Use `npm run android` only when extending/validating the optional Android target. Full workspace and Supabase instructions are in `../docs/SETUP.md`.

## Check

```powershell
npm run typecheck
npm test -- --runInBand
npm run lint
npm run windows -- --no-launch --no-packager
```

The first local rows are explicitly labeled sample data so the offline dashboard can be reviewed before the first authorized sync.
