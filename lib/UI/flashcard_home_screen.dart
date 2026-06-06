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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
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
  void _goNext() {
    if (_cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
      _resetCard();
    });
  }

  void _goPrev() {
    if (_cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
      _resetCard();
    });
  }

  // Hides answer and resets flip when moving to another card
  void _resetCard() {
    _showAnswer = false;
    _flipController.reverse();
  }

  //Flip Card
  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
      if (_showAnswer) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  //ADD Card
  Future<void> _addCard() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const CardDialog(),
    );
    if (result != null) {
      setState(() {
        widget.service.addCard(
          question: result['question']!,
          answer: result['answer']!,
        );
        _currentIndex = _cards.length - 1;
        _resetCard();
      });
    }
  }

  //Edit Card
  Future<void> _editCard(FlashCard card) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => CardDialog(card: card),
    );
    if (result != null) {
      setState(() {
        widget.service.updateCard(
          id: card.id,
          question: result['question']!,
          answer: result['answer']!,
        );
      });
    }
  }

  //Delete Card
  void _deleteCard(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Card?'),
        content: Text('This card will be permanently removed'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                widget.service.deleteCard(id);
                if (_cards.isEmpty) {
                  _currentIndex = 0;
                } else if (_currentIndex >= _cards.length) {
                  _currentIndex = _cards.length - 1;
                }
                _resetCard();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

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
            SizedBox(width: 8),
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

      body: _cards.isEmpty ? _buildEmptyState() : _buildCardView(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCard,
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('Add Card'),
      ),
    );
  }

  // Empty state: show when no cards exist
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.style_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No Flashcards yet!',
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap "Add Card" to create your first one',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Card view stub — implement rendering + flip animation
  Widget _buildCardView() {
    final card = _cards[_currentIndex];
    return Column(
      children: [
        SizedBox(height: 20),
        _buildProgressBar(),
        SizedBox(height: 24),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),

            child: _buildFlipCard(card),
          ),
        ),

        _buildShowAnswerButton(),
        SizedBox(height: 16),

        _buildNavButtons(),
        SizedBox(height: 90),
      ],
    );
  }

  Widget _buildFlipCard(FlashCard card) {
    return GestureDetector(
      onTap: _toggleAnswer,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _showAnswer ? card.answer : card.question,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildShowAnswerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        onPressed: _toggleAnswer,
        child: Text(_showAnswer ? 'Hide Answer' : 'Show Answer'),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: _goPrev, icon: Icon(Icons.arrow_back)),
        SizedBox(width: 16),
        IconButton(onPressed: _goNext, icon: Icon(Icons.arrow_forward)),
      ],
    );
  }

  //Progress Bar+Card Counter
  Widget _buildProgressBar() {
    final progrss = (_currentIndex + 1) / _cards.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${_currentIndex + 1} of ${_cards.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2563EB),
                ),
              ),
              Text(
                '${(progrss * 100).round()}% done',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),

          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progrss,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }
}
