import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const CrazyTubeApp());

class CrazyTubeApp extends StatelessWidget {
  const CrazyTubeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CrazyTube',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF8F7FB),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 92, height: 92, decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 58)),
              const SizedBox(height: 22),
              Text('CrazyTube', style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800)),
              const Text('Watch • Create • Earn'),
              const SizedBox(height: 42),
              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())), icon: const Icon(Icons.login), label: const Padding(padding: EdgeInsets.all(14), child: Text('Continue with Google')))),
              const SizedBox(height: 12),
              const Text('1 Google account = 1 CrazyTube channel', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            ]),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomePage(), ReelsPage(), UploadPage(), NotificationsPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library), label: 'Reels'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline, size: 32), selectedIcon: Icon(Icons.add_circle, size: 32), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'You'),
        ],
      ),
    );
  }
}

class VideoItem { final String title, creator, duration; final int views; const VideoItem(this.title, this.creator, this.duration, this.views); }
const videos = [
  VideoItem('Street Food Challenge 🔥', 'CrazyFood BD', '08:32', 12500),
  VideoItem('Amazing Rangpur Vlog', 'Sahad Vlogs', '06:18', 8300),
  VideoItem('Easy Chicken Burger Recipe', 'Food Lab', '09:45', 22100),
  VideoItem('Funny Moments 😂', 'Crazy Creator', '04:11', 53200),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverAppBar(title: const Text('CrazyTube'), floating: true, actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search)), IconButton(onPressed: () {}, icon: const Icon(Icons.account_balance_wallet_outlined))]),
    const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(16, 10, 16, 6), child: Text('For You', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
    SliverList(delegate: SliverChildBuilderDelegate((context, i) => VideoCard(video: videos[i]), childCount: videos.length)),
  ]);
}

class VideoCard extends StatelessWidget {
  final VideoItem video; const VideoCard({super.key, required this.video});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.fromLTRB(12, 8, 12, 8), clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPage(title: video.title))), child: AspectRatio(aspectRatio: 16/9, child: Container(color: Colors.black12, child: const Center(child: Icon(Icons.play_circle_fill, size: 64, color: Colors.deepPurple))))),
    ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${video.creator} • ${video.views} views • ${video.duration}'), trailing: const Icon(Icons.more_vert)),
    const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: Row(children: [Icon(Icons.thumb_up_alt_outlined, size: 20), SizedBox(width: 6), Text('Like'), SizedBox(width: 20), Icon(Icons.comment_outlined, size: 20), SizedBox(width: 6), Text('Comment'), Spacer(), Icon(Icons.share_outlined, size: 20)]))
  ]));
}

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Reels'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))]), body: PageView.builder(scrollDirection: Axis.vertical, itemCount: videos.length, itemBuilder: (_, i) => Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(18)), child: Stack(fit: StackFit.expand, children: [const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 76)), Positioned(left: 18, right: 18, bottom: 24, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(videos[i].title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('@${videos[i].creator.replaceAll(' ', '').toLowerCase()}', style: const TextStyle(color: Colors.white70))])), const Column(children: [Icon(Icons.favorite_border, color: Colors.white, size: 34), SizedBox(height: 18), Icon(Icons.comment_outlined, color: Colors.white, size: 32), SizedBox(height: 18), Icon(Icons.share_outlined, color: Colors.white, size: 32)])]))])));
}

class UploadPage extends StatefulWidget { const UploadPage({super.key}); @override State<UploadPage> createState() => _UploadPageState(); }
class _UploadPageState extends State<UploadPage> {
  final picker = ImagePicker(); String? picked; String type = 'Long Video';
  Future<void> pickVideo() async { final x = await picker.pickVideo(source: ImageSource.gallery); if (x == null) return; setState(() => picked = x.path); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create')), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Choose video type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
    SegmentedButton<String>(segments: const [ButtonSegment(value: 'Reel', label: Text('Reel'), icon: Icon(Icons.smartphone)), ButtonSegment(value: 'Long Video', label: Text('Long Video'), icon: Icon(Icons.ondemand_video))], selected: {type}, onSelectionChanged: (s) => setState(() => type = s.first)),
    const SizedBox(height: 22), OutlinedButton.icon(onPressed: pickVideo, icon: const Icon(Icons.video_library), label: Text(picked == null ? 'Select Video' : 'Video Selected')),
    if (type == 'Long Video') const Padding(padding: EdgeInsets.only(top: 10), child: Text('Maximum duration: 10 minutes', style: TextStyle(color: Colors.deepPurple))),
    const SizedBox(height: 22), TextField(decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())), const SizedBox(height: 14), TextField(maxLines: 4, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())), const SizedBox(height: 14), TextField(decoration: const InputDecoration(labelText: 'Hashtags', hintText: '#CrazyTube #Bangladesh', border: OutlineInputBorder())), const SizedBox(height: 24), FilledButton.icon(onPressed: picked == null ? null : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload queued in prototype. Backend required for real upload.'))), icon: const Icon(Icons.cloud_upload), label: const Padding(padding: EdgeInsets.all(12), child: Text('Publish')))
  ]));
}

class VideoPage extends StatefulWidget { final String title; const VideoPage({super.key, required this.title}); @override State<VideoPage> createState() => _VideoPageState(); }
class _VideoPageState extends State<VideoPage> { VideoPlayerController? controller; @override void dispose(){controller?.dispose(); super.dispose();} @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: Text(widget.title)), body: Column(children:[AspectRatio(aspectRatio:16/9, child: Container(color:Colors.black, child: const Center(child: Icon(Icons.play_circle_fill,color:Colors.white,size:72)))), ListTile(title:Text(widget.title,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:const Text('12.5K views • 2 days ago')), const Padding(padding:EdgeInsets.all(16),child:Row(children:[Icon(Icons.thumb_up_alt_outlined),SizedBox(width:8),Text('Like'),SizedBox(width:24),Icon(Icons.comment_outlined),SizedBox(width:8),Text('Comment'),Spacer(),Icon(Icons.share_outlined)])), const Divider(), const ListTile(leading:CircleAvatar(child:Icon(Icons.person)),title:Text('CrazyFood BD'),subtitle:Text('Food creator'),trailing:FilledButton(onPressed:null,child:Text('Follow')))])); }

class NotificationsPage extends StatelessWidget { const NotificationsPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Notifications')), body:ListView(children:const [ListTile(leading:Icon(Icons.favorite,color:Colors.red),title:Text('Someone liked your video'),subtitle:Text('Street Food Challenge')),ListTile(leading:Icon(Icons.person_add,color:Colors.deepPurple),title:Text('New follower'),subtitle:Text('Crazy Creator followed you')),ListTile(leading:Icon(Icons.monetization_on,color:Colors.green),title:Text('Earnings update'),subtitle:Text('Your estimated earning is ৳3,250'))])); } 

class ProfilePage extends StatelessWidget { const ProfilePage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('My Channel'),actions:[IconButton(onPressed:(){Navigator.push(context,MaterialPageRoute(builder:(_)=>const CreatorStudioPage()));},icon:const Icon(Icons.analytics_outlined))]), body:ListView(padding:const EdgeInsets.all(18),children:[const Center(child:CircleAvatar(radius:44,child:Icon(Icons.person,size:48))),const SizedBox(height:10),const Center(child:Text('My CrazyTube Channel',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),const Center(child:Text('@mychannel • 0 followers')),const SizedBox(height:22),Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:const [Stat('Videos','0'),Stat('Views','0'),Stat('Followers','0')]),const SizedBox(height:24),FilledButton.icon(onPressed:(){Navigator.push(context,MaterialPageRoute(builder:(_)=>const CreatorStudioPage()));},icon:const Icon(Icons.dashboard),label:const Text('Creator Studio')),const SizedBox(height:12),OutlinedButton.icon(onPressed:(){},icon:const Icon(Icons.settings),label:const Text('Settings'))])); }
class Stat extends StatelessWidget { final String a,b; const Stat(this.a,this.b,{super.key}); @override Widget build(BuildContext context)=>Column(children:[Text(b,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),Text(a)]); }

class CreatorStudioPage extends StatelessWidget { const CreatorStudioPage({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Creator Studio')),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('Overview',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:14),GridView.count(shrinkWrap:true,crossAxisCount:2,childAspectRatio:1.5,crossAxisSpacing:12,mainAxisSpacing:12,children:const [Metric('Total Views','125,450'),Metric('Followers','8,540'),Metric('Watch Time','1,240 h'),Metric('Estimated Earnings','৳3,250')]),const SizedBox(height:24),const Card(child:ListTile(leading:Icon(Icons.monetization_on,color:Colors.green),title:Text('Monetization'),subtitle:Text('Not connected in prototype'),trailing:Icon(Icons.chevron_right))),const Card(child:ListTile(leading:Icon(Icons.account_balance_wallet),title:Text('Wallet'),subtitle:Text('৳3,250 estimated'),trailing:Icon(Icons.chevron_right))),const Card(child:ListTile(leading:Icon(Icons.analytics),title:Text('Video Analytics'),subtitle:Text('Views, watch time, likes and retention'),trailing:Icon(Icons.chevron_right)))])); }
class Metric extends StatelessWidget { final String a,b; const Metric(this.a,this.b,{super.key}); @override Widget build(BuildContext context)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(b,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),Text(a)]))); }
