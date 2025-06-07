import 'package:flutter/material.dart';
import 'package:feels_mobile/widgets/app_card.dart';
import '../constants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppCard(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: AppColors.cardBackground.withValues(alpha: 0.5),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'About our app',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Feels is a social media platform focused on connecting with your closest friends instead of random individuals online. Our team developed this app as a university project, but it has since grown into something much more significant.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'A major social issue of the 21st century is social isolation — young people often hesitate to express their feelings, keeping them bottled up, while their friends assume everything is fine. This leads to many friendships lacking authenticity; instead of being founded on trust, they are based on both parties pretending their lives are flawless.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Social media exacerbates this problem, as modern platforms encourage users to create a false persona, selectively sharing information to present themselves in the best light. This curated version of reality often leads to feelings of inadequacy and disconnection among users.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This is where our app steps in. The feed consists solely of your closest friends — eliminating parasocial relationships. Each post conveys a specific emotion, providing your friends with an accurate understanding of how you are feeling. Additionally, we\'ve added a chat feature that allows you to quickly check in on your friends if you notice something off about their latest status.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'At Feels, our goal is to foster genuine connections and make emotional well-being a shared responsibility. We believe that honest communication between friends can make a meaningful difference in combating loneliness and promoting mental health.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'We hope Feels helps you stay more connected, more authentic, and more supported. Enjoy using our app 😊',
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
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
