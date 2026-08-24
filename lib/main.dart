import 'package:flutter/material.dart';

void main() {
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<String> videos = [
    'CrazyTube Featured Video',
    'Amazing Short Video',
    'Funny Moments',
    'Travel & Adventure',
    'Music & Entertainment',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7C4DFF),
                    Color(0xFFFF4081),
                  ],
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'CrazyTube',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 17,
              child: Icon(Icons.person, size: 20),
            ),
          ),
        ],
      ),

      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeFeed(videos: videos),
          const ReelsPage(),
          const CreatePage(),
          const WalletPage(),
          const ProfilePage(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF121217),
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
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
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
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

class HomeFeed extends StatelessWidget {
  final List<String> videos;

  const HomeFeed({
    super.key,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF24134D),
                Color(0xFF151522),
              ],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to CrazyTube 👋',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Watch, create & earn from your videos.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Trending Videos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        ...videos.asMap().entries.map(
          (entry) => VideoCard(
            title: entry.value,
            number: entry.key + 1,
          ),
        ),
      ],
    );
  }
}

class VideoCard extends StatelessWidget {
  final String title;
  final int number;

  const VideoCard({
    super.key,
    required this.title,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF15151C),
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF311B92 + (number * 100)),
                    const Color(0xFF12121A),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 4),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 19,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(62, 0, 12, 12),
            child: Text(
              'CrazyTube Creator • 1.2K views • 2h ago',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(55, 0, 12, 12),
            child: Row(
              children: [
                Icon(Icons.thumb_up_outlined, size: 19),
                SizedBox(width: 5),
                Text('245'),
                SizedBox(width: 20),
                Icon(Icons.comment_outlined, size: 19),
                SizedBox(width: 5),
                Text('32'),
                SizedBox(width: 20),
                Icon(Icons.share_outlined, size: 19),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF30206B),
                Color(0xFF09090D),
              ],
            ),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 75,
                  color: Colors.white70,
                ),
              ),

              Positioned(
                left: 18,
                right: 75,
                bottom: 25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CrazyTube Reel #${index + 1}',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Watch this amazing short video on CrazyTube.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 15,
                bottom: 25,
                child: Column(
                  children: [
                    _ReelButton(
                      icon: Icons.favorite_border,
                      text: '1.2K',
                    ),
                    _ReelButton(
                      icon: Icons.comment_outlined,
                      text: '248',
                    ),
                    _ReelButton(
                      icon: Icons.share_outlined,
                      text: 'Share',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReelButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReelButton({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7C4DFF),
                    Color(0xFFFF4081),
                  ],
                ),
              ),
              child: const Icon(
                Icons.video_call,
                size: 48,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Create on CrazyTube',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload a Reel or a Long Video up to 10 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Upload system will be connected next.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload Video'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Wallet & Earnings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4527A0),
                Color(0xFF7B1FA2),
              ],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Earnings',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 8),
              Text(
                '৳ 3,250',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '+12.5% this month',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.monetization_on),
          ),
          title: Text('Creator Earnings'),
          subtitle: Text('Video monetization'),
          trailing: Text('৳ 2,450'),
        ),

        const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.ads_click),
          ),
          title: Text('Ad Revenue'),
          subtitle: Text('Advertisements'),
          trailing: Text('৳ 800'),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: () {},
            child: const Text('Request Withdrawal'),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 15),

        const Center(
          child: CircleAvatar(
            radius: 48,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),
        ),

        const SizedBox(height: 14),

        const Center(
          child: Text(
            'CrazyTube Creator',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const Center(
          child: Text(
            '@crazycreator',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ),

        const SizedBox(height: 25),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _ProfileStat(
              number: '125',
              label: 'Videos',
            ),
            _ProfileStat(
              number: '12.5K',
              label: 'Followers',
            ),
            _ProfileStat(
              number: '850K',
              label: 'Views',
            ),
          ],
        ),

        const SizedBox(height: 25),

        ListTile(
          leading: const Icon(Icons.video_library),
          title: const Text('Creator Studio'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),

        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),

        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String number;
  final String label;

  const _ProfileStat({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
