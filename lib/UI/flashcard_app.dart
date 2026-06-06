import 'package:flutter/material.dart';
import 'package:flashcard_quiz_app/UI/flashcard_home_screen.dart';
import 'package:flashcard_quiz_app/services/flashcard_service.dart';

class FlashCardApp extends StatelessWidget {
  const FlashCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/flashCardView': (context) => FlashCardHomeScreen(service: FlashcardService())
      },
      initialRoute: '/flashCardView',
      title: 'FlashCards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        fontFamily: 'Robato',
        useMaterial3: false,

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14,vertical: 12),
        ),
      ),
    );
  }
}
