import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? firebaseError;

  try {
    await Firebase.initializeApp();
  } catch (e) {
    firebaseError = e.toString();
    debugPrint('Firebase initialization error: $e');
  }

  runApp(CrazyTubeApp(firebaseError: firebaseError));
}

class CrazyTubeApp extends StatelessWidget {
  final String? firebaseError;

  const CrazyTubeApp({
    super.key,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CrazyTube',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: firebaseError != null
          ? FirebaseErrorPage(error: firebaseError!)
          : const AuthGate(),
    );
  }
}

// ------------------------------------------------------------
// FIREBASE ERROR PAGE
// ------------------------------------------------------------

class FirebaseErrorPage extends StatelessWidget {
  final String error;

  const FirebaseErrorPage({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrazyTube'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 70,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Firebase initialization failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SelectableText(
                  error,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// AUTH GATE
// ------------------------------------------------------------

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashPage();
        }

        if (snapshot.hasError) {
          return ErrorPage(
            message: snapshot.error.toString(),
          );
        }

        if (snapshot.data == null) {
          return const LoginPage();
        }

        return const ChannelCheckPage();
      },
    );
  }
}

// ------------------------------------------------------------
// SPLASH
// ------------------------------------------------------------

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_fill,
              size: 90,
            ),
            SizedBox(height: 20),
            Text(
              'CrazyTube',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// GOOGLE LOGIN
// ------------------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;
  String? errorMessage;

  Future<void> signInWithGoogle() async {
    if (loading) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
          'Google ID token is null. Check Firebase/Google Sign-In configuration.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } on GoogleSignInException catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          errorMessage =
              'Google Login failed:\n${e.code}\n${e.description ?? ''}';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          errorMessage =
              'Firebase Login failed:\n${e.code}\n${e.message ?? ''}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          errorMessage = 'Google Login failed:\n$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_fill,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'CrazyTube',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Watch. Create. Share.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: loading ? null : signInWithGoogle,
                    icon: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      loading
                          ? 'Signing in...'
                          : 'Continue with Google',
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(),
                    ),
                    child: SelectableText(
                      errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// CHANNEL CHECK
// ------------------------------------------------------------

class ChannelCheckPage extends StatelessWidget {
  const ChannelCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CrazyTube'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 90,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome ${user?.displayName ?? 'to CrazyTube'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateChannelPage(),
                      ),
                    );
                  },
                  child: const Text('Create Channel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// CREATE CHANNEL
// ------------------------------------------------------------

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final TextEditingController channelController =
      TextEditingController();

  bool saving = false;
  String? message;

  Future<void> createChannel() async {
    final name = channelController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (name.isEmpty) {
      setState(() {
        message = 'Please enter a channel name.';
      });
      return;
    }

    if (user == null) {
      setState(() {
        message = 'Please login first.';
      });
      return;
    }

    setState(() {
      saving = true;
      message = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('channels')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': name,
        'email': user.email,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          saving = false;
          message = 'Channel created successfully!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          saving = false;
          message = 'Channel creation failed:\n$e';
        });
      }
    }
  }

  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Channel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: channelController,
              decoration: const InputDecoration(
                labelText: 'Channel name',
                hintText: 'Enter your channel name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: saving ? null : createChannel,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text('Create Channel'),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              SelectableText(
                message!,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// GENERIC ERROR PAGE
// ------------------------------------------------------------

class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
