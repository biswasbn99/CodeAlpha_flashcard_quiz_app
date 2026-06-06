import 'package:flutter/material.dart';
import 'package:flashcard_quiz_app/services/flashcard_service.dart';
import 'package:flashcard_quiz_app/model/flashcard_model.dart';
import 'package:flashcard_quiz_app/widget/card_dialog.dart';

class FlashCardHomeScreen extends StatefulWidget {
  final FlashcardService service;
  const FlashCardHomeScreen({super.key, required this.service});

  @override
  State<FlashCardHomeScreen> createState() => _FlashCardHomeScreenState();
}

class _FlashCardHomeScreenState extends State<FlashCardHomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;

  //Animation controller
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _flipController.dispose();
    super.dispose();
  }

  List<FlashCard> get _cards => widget.service.allCards;

  //Navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          children: [
            Icon(Icons.style_rounded, size: 22),
            SizedBox(height: 8),
            Text('FlashCards', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 46),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_cards.length} cards',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
