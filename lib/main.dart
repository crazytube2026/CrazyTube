import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const CrazyTubeApp());
}

class CrazyTubeApp extends StatelessWidget {
  const CrazyTubeApp({super.key});

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
      home: const AuthGate(),
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
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
// GOOGLE LOGIN
// ------------------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  Future<void> signInWithGoogle() async {
    setState(() {
      loading = true;
    });

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Login failed: $e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CrazyTube logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7C4DFF),
                      Color(0xFFFF4081),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'CrazyTube',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Watch, Create & Earn',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                      loading ? null : signInWithGoogle,
                  icon: const Icon(Icons.login),
                  label: Text(
                    loading
                        ? 'Signing in...'
                        : 'Continue with Google',
                  ),
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
// CHECK CHANNEL
// ------------------------------------------------------------

class ChannelCheckPage extends StatelessWidget {
  const ChannelCheckPage({super.key});

  Future<bool> channelExists() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final doc = await FirebaseFirestore.instance
        .collection('channels')
        .doc(user.uid)
        .get();

    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: channelExists(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const HomePage();
        }

        return const CreateChannelPage();
      },
    );
  }
}

// ------------------------------------------------------------
// CREATE CHANNEL
// ------------------------------------------------------------

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() =>
      _CreateChannelPageState();
}

class _CreateChannelPageState
    extends State<CreateChannelPage> {
  final TextEditingController channelNameController =
      TextEditingController();

  bool creating = false;

  Future<void> createChannel() async {
    final channelName =
        channelNameController.text.trim();

    if (channelName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a channel name.',
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      creating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('channels')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email,
        'channelName': channelName,
        'photoUrl': user.photoURL,
        'followers': 0,
        'views': 0,
        'videos': 0,
        'earnings': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Channel creation failed: $e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        creating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Your Channel',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 55,
              backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
              child: user?.photoURL == null
                  ? const Icon(
                      Icons.person,
                      size: 55,
                    )
                  : null,
            ),

            const SizedBox(height: 25),

            const Text(
              'Create your CrazyTube Channel',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: channelNameController,
              decoration: InputDecoration(
                labelText: 'Channel Name',
                hintText: 'Example: Crazy Creator',
                prefixIcon: const Icon(
                  Icons.video_library,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed:
                    creating ? null : createChannel,
                icon: const Icon(
                  Icons.add_circle,
                ),
                label: Text(
                  creating
                      ? 'Creating Channel...'
                      : 'Create Channel',
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text(
                'Use another Google Account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// HOME
// ------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeFeed(),
    ReelsPage(),
    CreatePage(),
    EarningsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon:
                Icon(Icons.account_balance_wallet),
            label: 'Earn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// HOME FEED
// ------------------------------------------------------------

class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CrazyTube',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .limit(30)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final videos =
              snapshot.data?.docs ?? [];

          if (videos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text(
                  'Welcome to CrazyTube! 🎉\n\n'
                  'No videos yet.\n'
                  'Be the first creator!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final data =
                  videos[index].data();

              return VideoCard(
                title:
                    data['title'] ??
                        'Untitled Video',
                type:
                    data['type'] ??
                        'Long Video',
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// VIDEO CARD
// ------------------------------------------------------------

class VideoCard extends StatelessWidget {
  final String title;
  final String type;

  const VideoCard({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF311B92),
                    Color(0xFF15151C),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 65,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CrazyTube Creator • $type',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.more_vert,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// REELS
// ------------------------------------------------------------

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CrazyTube Reels'),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4527A0),
                  Color(0xFF09090D),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 80,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// CREATE / UPLOAD
// ------------------------------------------------------------

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_call,
                size: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                'Create on CrazyTube',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Upload Reels or Long Videos.\n'
                'Long videos can be up to 10 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 25),

              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Video upload system will be connected next.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.upload,
                ),
                label: const Text(
                  'Upload Video',
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
// EARNINGS
// ------------------------------------------------------------

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Creator Earnings',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4527A0),
                  Color(0xFF7B1FA2),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Earnings',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '৳ 0',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.monetization_on,
              ),
            ),
            title: Text(
              'Creator Earnings',
            ),
            subtitle: Text(
              'Complete targets to qualify.',
            ),
          ),

          const ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.analytics,
              ),
            ),
            title: Text(
              'Channel Performance',
            ),
            subtitle: Text(
              'Views, followers and videos.',
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE
// ------------------------------------------------------------

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Channel',
        ),
        actions: [
          IconButton(
            onPressed: () =>
                FirebaseAuth.instance.signOut(),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('channels')
            .doc(user?.uid)
            .snapshots(),

        builder: (context, snapshot) {
          final data =
              snapshot.data?.data();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 15),

              CircleAvatar(
                radius: 50,
                backgroundImage:
                    user?.photoURL != null
                        ? NetworkImage(
                            user!.photoURL!,
                          )
                        : null,
                child:
                    user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                          )
                        : null,
              ),

              const SizedBox(height: 15),

              Center(
                child: Text(
                  data?['channelName'] ??
                      'My Channel',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(
                    value:
                        '${data?['videos'] ?? 0}',
                    label: 'Videos',
                  ),
                  _Stat(
                    value:
                        '${data?['followers'] ?? 0}',
                    label: 'Followers',
                  ),
                  _Stat(
                    value:
                        '${data?['views'] ?? 0}',
                    label: 'Views',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
