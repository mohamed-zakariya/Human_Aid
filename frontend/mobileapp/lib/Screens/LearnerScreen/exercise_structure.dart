import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mobileapp/Services/words_service.dart';
import 'package:mobileapp/models/exercices_progress.dart';
import 'package:mobileapp/models/learner.dart';
import 'package:video_player/video_player.dart';

class Exercisestructure extends StatefulWidget {
  const Exercisestructure({super.key, required this.learner});
  final Learner learner;

  @override
  State<Exercisestructure> createState() => _ExercisestructureState();
}

class _ExercisestructureState extends State<Exercisestructure> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;
  late VideoPlayerController _videoController;
  bool _isVideoPlaying = false;
  bool isLoading = true, isLoading2 = true;


  late List<String> correctWords = [];

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/1.mp4')
      ..initialize().then((_) {
        setState(() {
          isLoading2 = false; // ✅ Video loaded, stop loading indicator
        });
        _videoController.setLooping(false);
      }).catchError((error) {
        print("Video load error: $error");
        setState(() {
          isLoading2 = false; // ✅ Ensure UI updates even if video fails
        });
      });

    _videoController.addListener(() {
      if (!_videoController.value.isPlaying &&
          _videoController.value.position == _videoController.value.duration) {
        setState(() {
          _isVideoPlaying = false;
        });
      }
    });

    getLearntData(); // ✅ Fetch the correct words
  }


  void getLearntData() async {
    try {
      ExerciseProgress? exerciseProgress = await WordsService.getLearntDataById(widget.learner.id);
      setState(() {
        correctWords = exerciseProgress?.correctWords ?? [];
        isLoading = false; // ✅ Stop loading after fetching words
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false; // ✅ Ensure UI updates even if an error occurs
      });
    }
  }


  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void playAudio() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource("audio/63.m4a"));
    } catch (e) {
      print("Audio error: $e");
    }
  }

  void _toggleVideoPlayback() {
    if (_videoController.value.isInitialized) {
      setState(() {
        if (_videoController.value.isPlaying) {
          _videoController.pause();
          _isVideoPlaying = false;
        } else {
          _videoController.play();
          _isVideoPlaying = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect language direction
    bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Word Exercise"),
        ),
        body: (isLoading || isLoading2)?
        const Center(child: CircularProgressIndicator())
        :Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Video Player with Play/Pause Icon Overlay**
              _videoController.value.isInitialized
                  ? GestureDetector(
                onTap: _toggleVideoPlayback,
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height/4.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent, // Background color for better visibility
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                        if (!_isVideoPlaying) // Show play icon when video is paused
                          Icon(
                            Icons.play_circle_fill,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          )
                        else // Show pause icon when video is playing
                          Icon(
                            Icons.pause_circle_filled,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          ),
                      ],
                    ),
                  ),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 5),

              // Course Title & Info
              const Text(
                "Word Learning Exercise",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Enhance your pronunciation and vocabulary through guided practice",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              // Tabs
              const TabBar(
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                tabs: [
                  Tab(text: "Learnt Words"),
                  Tab(text: "Description"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    // **Correct Words Tab**
                    correctWords.isEmpty
                        ? const Center(child: Text("No words yet. Start learning!"))
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        // **Carousel with Navigation Buttons**
                        Stack(
                          children: [
                            CarouselSlider(
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.height/3.7,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                viewportFraction: 0.85,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                              items: correctWords.map((word) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width - 50,
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // ✅ **Word Image**
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            'assets/images/Apple.png', // Replace with actual image paths
                                            // width: MediaQuery.of(context).size.width/5,
                                            height: MediaQuery.of(context).size.height/12,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // ✅ **Word Text**
                                        Text(
                                          word,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // ✅ **Pronunciation Button**
                                        IconButton(
                                          icon: const Icon(Icons.volume_up, size: 40, color: Colors.deepPurple),
                                          onPressed: playAudio,
                                        ),

                                        // ✅ **Progress Indicator**
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: LinearProgressIndicator(
                                            value: (_currentIndex + 1) / correctWords.length, // Dynamic progress
                                            backgroundColor: Colors.grey[300],
                                            color: Colors.deepPurple,
                                            minHeight: 10,
                                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            // **Left Button**
                            if (_currentIndex > 0)
                              Positioned(
                                left: isRTL ? null : 10,
                                right: isRTL ? 10 : null,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _carouselController.previousPage(),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    size: 28,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),

                            // **Right Button**
                            if (_currentIndex < correctWords.length - 1)
                              Positioned(
                                right: isRTL ? null : 10,
                                left: isRTL ? 10 : null,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => _carouselController.nextPage(),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 28,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // **Description Tab**
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🔹 Enhance Your Pronunciation & Vocabulary",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.05, // Responsive size
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          Text(
                            "🗣️ You'll have **three attempts** to pronounce each word correctly. If you struggle, a new word will be provided.",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                          Text(
                            "🎧 Tap the **audio button** to listen to the correct pronunciation before speaking.",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.008),
                          Text(
                            "🔄 You can **revisit and listen** to previously attempted words to refine your pronunciation.",
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                          Center(
                            child: Text(
                              "✨ Practice, listen, and master new words with ease!",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.04,
                                fontStyle: FontStyle.italic,
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              // **Start or Continue Button**
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  setState(() {
                    correctWords.add("Grapes");
                  });
                },
                child: Text(correctWords.isEmpty ? "Start Now" : "Continue",
                    style: const TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
