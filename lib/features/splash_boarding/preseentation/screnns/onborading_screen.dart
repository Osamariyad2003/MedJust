import 'package:flutter/material.dart';
import 'package:med_just/core/routes/routers.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Med Just',
      'subtitle': 'Your gateway to seamless healthcare management.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Manage Appointments',
      'subtitle': 'Schedule and track your appointments with ease.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Access Medical Records',
      'subtitle': 'Securely view and share your medical history.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, Routers.homeRoute);
    }
  }

  Widget _buildPage(Map<String, String> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(page['image']!, height: 300),
          const SizedBox(height: 40),
          Text(
            page['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            page['subtitle']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (_, index) => _buildPage(_pages[index]),
            ),
          ),
          _buildIndicator(),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onNext,
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
