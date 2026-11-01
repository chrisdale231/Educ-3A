import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  useWindowDimensions,
  View,
} from 'react-native';
import { backendConfigured } from './src/config';
import {
  loadDashboard,
  openTeacherDatabase,
  outboxCount,
  setPublished,
  teacherDatabaseFile,
} from './src/data/database';
import { supabase } from './src/services/supabase';
import { syncTeacherChanges } from './src/services/sync';
import type { DashboardData } from './src/types';

const navItems = [
  'Overview',
  'Classes',
  'Lessons / Sessions',
  'Quizzes',
  'Results',
  'Progress',
  'Reports',
  'Settings',
] as const;
type Page = (typeof navItems)[number];
const emptyData: DashboardData = {
  classes: [],
  students: [],
  lessons: [],
  quizzes: [],
  results: [],
};

function App(): React.JSX.Element {
  const { width } = useWindowDimensions();
  const compact = width < 850;
  const [page, setPage] = useState<Page>('Overview');
  const [data, setData] = useState(emptyData);
  const [busy, setBusy] = useState(true);
  const [pending, setPending] = useState(0);
  const [message, setMessage] = useState('Opening offline database…');
  const [signedInEmail, setSignedInEmail] = useState<string>();
  const refresh = useCallback(async () => {
    setData(await loadDashboard());
    setPending(await outboxCount());
  }, []);
  useEffect(() => {
    const initialize = async () => {
      try {
        await openTeacherDatabase();
        await refresh();
        const session = await supabase?.auth.getSession();
        setSignedInEmail(session?.data.session?.user.email);
        setMessage(
          backendConfigured
            ? 'Saved locally'
            : 'Offline demo • Supabase not configured',
        );
      } catch (error) {
        setMessage(`Database error: ${String(error)}`);
      } finally {
        setBusy(false);
      }
    };
    initialize().catch(error => setMessage(`Database error: ${String(error)}`));
  }, [refresh]);
  const sync = useCallback(async () => {
    setMessage('Syncing…');
    const result = await syncTeacherChanges();
    await refresh();
    setMessage(result.error ?? `${result.synced} change(s) synced`);
  }, [refresh]);
  useEffect(() => {
    if (!signedInEmail || !backendConfigured) return;
    sync().catch(error => setMessage(`Sync error: ${String(error)}`));
  }, [signedInEmail, sync]);
  useEffect(() => {
    const timer = setInterval(() => {
      if (backendConfigured) {
        sync().catch(error => setMessage(`Sync error: ${String(error)}`));
      }
    }, 30000);
    return () => clearInterval(timer);
  }, [sync]);
  const togglePublished = async (
    kind: 'lessons' | 'quizzes',
    id: string,
    value: boolean,
  ) => {
    await setPublished(kind, id, value);
    await refresh();
    setMessage('Saved locally • pending sync');
  };
  if (busy)
    return (
      <SafeAreaView style={styles.loading}>
        <ActivityIndicator size="large" color="#16b8d8" />
        <Text style={styles.muted}>{message}</Text>
      </SafeAreaView>
    );
  return (
    <SafeAreaView style={styles.app}>
      <View style={[styles.shell, compact && styles.shellCompact]}>
        <View style={[styles.sidebar, compact && styles.sidebarCompact]}>
          <View>
            <Text style={styles.brand}>BEACON</Text>
            <Text style={styles.brandSub}>Teacher workspace</Text>
          </View>
          <ScrollView
            horizontal={compact}
            contentContainerStyle={compact ? styles.navCompact : undefined}
          >
            {navItems.map(item => (
              <Pressable
                key={item}
                accessibilityRole="button"
                accessibilityState={{ selected: page === item }}
                onPress={() => setPage(item)}
                style={[styles.navItem, page === item && styles.navSelected]}
              >
                <Text
                  style={[
                    styles.navText,
                    page === item && styles.navTextSelected,
                  ]}
                >
                  {item}
                </Text>
              </Pressable>
            ))}
          </ScrollView>
          {!compact && (
            <Text style={styles.databaseHint}>
              Offline file{`\n`}
              {teacherDatabaseFile}
            </Text>
          )}
        </View>
        <View style={styles.main}>
          <View style={styles.topbar}>
            <View>
              <Text style={styles.heading}>{page}</Text>
              <Text style={styles.muted}>{message}</Text>
            </View>
            <View style={styles.topActions}>
              <Text style={styles.pending}>
                {pending === 0 ? '✓ Synced/local' : `${pending} pending`}
              </Text>
              <Pressable
                accessibilityRole="button"
                onPress={sync}
                style={styles.primaryButton}
              >
                <Text style={styles.primaryButtonText}>Sync now</Text>
              </Pressable>
              <AccountButton
                email={signedInEmail}
                onSignedIn={setSignedInEmail}
              />
            </View>
          </View>
          <ScrollView contentContainerStyle={styles.content}>
            <PageContent
              page={page}
              data={data}
              onTogglePublished={togglePublished}
            />
          </ScrollView>
        </View>
      </View>
    </SafeAreaView>
  );
}

function AccountButton({
  email,
  onSignedIn,
}: {
  email?: string;
  onSignedIn: (email?: string) => void;
}) {
  const [show, setShow] = useState(false);
  const [inputEmail, setInputEmail] = useState('');
  const [password, setPassword] = useState('');
  const submit = async () => {
    if (!supabase)
      return Alert.alert(
        'Offline mode',
        'Set the Supabase URL and anon key in src/config.ts. Never use a service-role key in this app.',
      );
    const response = await supabase.auth.signInWithPassword({
      email: inputEmail.trim(),
      password,
    });
    if (response.error)
      return Alert.alert('Sign-in failed', response.error.message);
    onSignedIn(response.data.user.email);
    setShow(false);
  };
  if (email)
    return (
      <Pressable
        style={styles.accountButton}
        onPress={async () => {
          await supabase?.auth.signOut();
          onSignedIn(undefined);
        }}
      >
        <Text style={styles.accountText}>{email} • Sign out</Text>
      </Pressable>
    );
  return (
    <View>
      <Pressable
        style={styles.accountButton}
        onPress={() => setShow(value => !value)}
      >
        <Text style={styles.accountText}>Teacher sign in</Text>
      </Pressable>
      {show && (
        <View style={styles.signInPanel}>
          <TextInput
            accessibilityLabel="Teacher email"
            placeholder="Teacher email"
            value={inputEmail}
            onChangeText={setInputEmail}
            style={styles.input}
          />
          <TextInput
            accessibilityLabel="Password"
            placeholder="Password"
            secureTextEntry
            value={password}
            onChangeText={setPassword}
            style={styles.input}
          />
          <Pressable onPress={submit} style={styles.primaryButton}>
            <Text style={styles.primaryButtonText}>Sign in</Text>
          </Pressable>
        </View>
      )}
    </View>
  );
}

function PageContent({
  page,
  data,
  onTogglePublished,
}: {
  page: Page;
  data: DashboardData;
  onTogglePublished: (
    kind: 'lessons' | 'quizzes',
    id: string,
    value: boolean,
  ) => Promise<void>;
}) {
  const average = useMemo(
    () =>
      data.students.length
        ? Math.round(
            data.students.reduce((sum, item) => sum + item.completion, 0) /
              data.students.length,
          )
        : 0,
    [data.students],
  );
  if (page === 'Overview')
    return (
      <>
        <View style={styles.metricRow}>
          <Metric label="Classes" value={data.classes.length} />
          <Metric label="Students" value={data.students.length} />
          <Metric
            label="Published lessons"
            value={data.lessons.filter(x => x.published).length}
          />
          <Metric label="Average progress" value={`${average}%`} />
        </View>
        <Section title="Recent synced submissions">
          <ResultTable results={data.results} />
        </Section>
        <SampleNotice />
      </>
    );
  if (page === 'Classes')
    return (
      <Section title="Classes and students">
        {data.classes.map(item => (
          <Card
            key={item.id}
            title={item.name}
            detail={`Grade ${item.gradeLevel} • ${item.studentCount} student(s)`}
          />
        ))}
        {data.students.map(item => (
          <Card
            key={item.id}
            title={item.name}
            detail={`${item.className} • ${item.completion}% complete`}
          />
        ))}
      </Section>
    );
  if (page === 'Lessons / Sessions')
    return (
      <Section title="Lesson and session management">
        {data.lessons.map(item => (
          <ManageCard
            key={item.id}
            title={`Session ${item.sessionNumber}: ${item.title}`}
            published={item.published}
            onToggle={() =>
              onTogglePublished('lessons', item.id, !item.published)
            }
          />
        ))}
      </Section>
    );
  if (page === 'Quizzes')
    return (
      <Section title="Quiz management">
        {data.quizzes.map(item => (
          <ManageCard
            key={item.id}
            title={item.title}
            detail={`Pass: ${item.passingScore}/10`}
            published={item.published}
            onToggle={() =>
              onTogglePublished('quizzes', item.id, !item.published)
            }
          />
        ))}
      </Section>
    );
  if (page === 'Results')
    return (
      <Section title="Submitted results">
        <Text style={styles.muted}>
          A student submission appears here only after that student's device
          successfully syncs.
        </Text>
        <ResultTable results={data.results} />
      </Section>
    );
  if (page === 'Progress')
    return (
      <Section title="Student progress">
        {data.students.map(item => (
          <View key={item.id} style={styles.progressRow}>
            <Text style={styles.cardTitle}>{item.name}</Text>
            <View style={styles.track}>
              <View style={[styles.fill, { width: `${item.completion}%` }]} />
            </View>
            <Text>{item.completion}%</Text>
          </View>
        ))}
      </Section>
    );
  if (page === 'Reports')
    return (
      <Section title="Basic class report">
        <Text style={styles.reportBig}>{average}%</Text>
        <Text style={styles.muted}>
          Average completion across locally available students
        </Text>
        <Text style={styles.body}>
          Published lessons: {data.lessons.filter(x => x.published).length} /{' '}
          {data.lessons.length}
        </Text>
        <Text style={styles.body}>
          Synced submissions: {data.results.length}
        </Text>
      </Section>
    );
  return (
    <Section title="Settings">
      <Text style={styles.body}>Local database: {teacherDatabaseFile}</Text>
      <Text style={styles.body}>
        Backend:{' '}
        {backendConfigured
          ? 'Configured with public anon key'
          : 'Not configured — offline demo mode'}
      </Text>
      <Text style={styles.muted}>
        Never add the Supabase service-role key to this client.
      </Text>
    </Section>
  );
}

function Metric({ label, value }: { label: string; value: string | number }) {
  return (
    <View style={styles.metric}>
      <Text style={styles.metricValue}>{value}</Text>
      <Text style={styles.muted}>{label}</Text>
    </View>
  );
}
function Section({
  title,
  children,
}: React.PropsWithChildren<{ title: string }>) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}
function Card({ title, detail }: { title: string; detail: string }) {
  return (
    <View style={styles.card}>
      <Text style={styles.cardTitle}>{title}</Text>
      <Text style={styles.muted}>{detail}</Text>
    </View>
  );
}
function ManageCard({
  title,
  detail,
  published,
  onToggle,
}: {
  title: string;
  detail?: string;
  published: boolean;
  onToggle: () => void;
}) {
  return (
    <View style={styles.manageCard}>
      <View>
        <Text style={styles.cardTitle}>{title}</Text>
        {detail && <Text style={styles.muted}>{detail}</Text>}
      </View>
      <Pressable
        accessibilityRole="switch"
        accessibilityState={{ checked: published }}
        onPress={onToggle}
        style={[styles.publishButton, published && styles.published]}
      >
        <Text style={published ? styles.primaryButtonText : styles.cardTitle}>
          {published ? 'Published' : 'Draft'}
        </Text>
      </Pressable>
    </View>
  );
}
function ResultTable({ results }: { results: DashboardData['results'] }) {
  return results.length === 0 ? (
    <Text style={styles.empty}>No synced submissions yet.</Text>
  ) : (
    <View>
      {results.map(item => (
        <Card
          key={item.id}
          title={`${item.studentName} — ${item.score}/${item.total}`}
          detail={`${item.quizTitle} • synced ${item.syncedAt}`}
        />
      ))}
    </View>
  );
}
function SampleNotice() {
  return (
    <Text style={styles.sample}>
      SAMPLE CONTENT: Replace the seeded class, learner, lessons, and quizzes
      with approved school content.
    </Text>
  );
}

const styles = StyleSheet.create({
  app: { flex: 1, backgroundColor: '#eaf7fb' },
  shell: { flex: 1, flexDirection: 'row' },
  shellCompact: { flexDirection: 'column' },
  loading: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 12 },
  sidebar: { width: 245, backgroundColor: '#072943', padding: 24, gap: 28 },
  sidebarCompact: { width: '100%', padding: 12, gap: 8 },
  brand: {
    color: '#66e1ee',
    fontSize: 28,
    fontWeight: '900',
    letterSpacing: 3,
  },
  brandSub: { color: '#b8d8e6' },
  navCompact: { gap: 8 },
  navItem: {
    paddingVertical: 13,
    paddingHorizontal: 14,
    borderRadius: 10,
    marginBottom: 4,
  },
  navSelected: { backgroundColor: '#0e7893' },
  navText: { color: '#cbe3ed', fontWeight: '600' },
  navTextSelected: { color: 'white' },
  databaseHint: { marginTop: 'auto', fontSize: 11, color: '#81a9ba' },
  main: { flex: 1 },
  topbar: {
    zIndex: 5,
    minHeight: 90,
    paddingHorizontal: 28,
    paddingVertical: 16,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderColor: '#cae6ef',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 16,
  },
  heading: { fontSize: 28, fontWeight: '800', color: '#08233f' },
  topActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    flexWrap: 'wrap',
    justifyContent: 'flex-end',
  },
  pending: { fontWeight: '700', color: '#8a5b00' },
  primaryButton: {
    backgroundColor: '#087f9d',
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 9,
    alignItems: 'center',
  },
  primaryButtonText: { color: 'white', fontWeight: '800' },
  accountButton: {
    borderWidth: 1,
    borderColor: '#0e7893',
    padding: 9,
    borderRadius: 9,
    backgroundColor: 'white',
  },
  accountText: { color: '#075d76', fontWeight: '700' },
  signInPanel: {
    position: 'absolute',
    right: 0,
    top: 48,
    width: 280,
    backgroundColor: 'white',
    padding: 14,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 12,
    gap: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#9fcbd7',
    borderRadius: 8,
    padding: 10,
  },
  content: { padding: 28, gap: 18 },
  metricRow: { flexDirection: 'row', gap: 14, flexWrap: 'wrap' },
  metric: {
    minWidth: 170,
    flexGrow: 1,
    backgroundColor: 'white',
    borderWidth: 1,
    borderColor: '#b9e4ed',
    borderRadius: 14,
    padding: 20,
  },
  metricValue: { fontSize: 32, fontWeight: '900', color: '#087f9d' },
  muted: { color: '#547080', marginTop: 4 },
  section: {
    backgroundColor: 'white',
    padding: 22,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#b9e4ed',
    gap: 12,
  },
  sectionTitle: { fontSize: 21, fontWeight: '800', color: '#08233f' },
  card: { borderBottomWidth: 1, borderColor: '#dfedf2', paddingVertical: 12 },
  cardTitle: { fontWeight: '800', fontSize: 16, color: '#102b45' },
  manageCard: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 14,
    borderWidth: 1,
    borderColor: '#c7e5ed',
    borderRadius: 12,
    gap: 12,
  },
  publishButton: {
    minWidth: 100,
    padding: 10,
    alignItems: 'center',
    borderRadius: 9,
    backgroundColor: '#e6f3f6',
  },
  published: { backgroundColor: '#087f9d' },
  empty: { padding: 20, textAlign: 'center', color: '#547080' },
  sample: {
    color: '#805600',
    backgroundColor: '#fff5cf',
    padding: 14,
    borderRadius: 10,
  },
  progressRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingVertical: 10,
  },
  track: {
    height: 12,
    backgroundColor: '#d7e8ee',
    borderRadius: 6,
    flex: 1,
    overflow: 'hidden',
  },
  fill: { height: '100%', backgroundColor: '#15b8cf' },
  reportBig: { fontSize: 64, fontWeight: '900', color: '#087f9d' },
  body: { fontSize: 16, color: '#203f55' },
});
export default App;
