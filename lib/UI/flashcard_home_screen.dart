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
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
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

  //Animation flip card
  Widget _buildFlipCard(FlashCard card) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.14159;
        final showFront = _flipAnimation.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showFront
              ? _buildCardFace(card, isFront: true)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.14159),
                  child: _buildCardFace(card, isFront: false),
                ),
        );
      },
    );
  }

  //one side of the card
  Widget _buildCardFace(FlashCard card, {required bool isFront}) {
    final bgcolor = isFront ? Colors.white : Color(0xFFEFFFF5);
    final labelColor = isFront ? Color(0xFF2563EB) : Color(0xFF16A34A);
    final labelBg = isFront ? Color(0xFFEFF6FF) : Color(0xFFEFF6FF);

    final labelText = isFront ? 'QUESTION' : 'ANSWER';
    final bodyText = isFront ? card.question : card.answer;
    final borderColor = labelColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: labelBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),

            child: Row(
              children: [
                Icon(
                  isFront
                      ? Icons.help_outline_rounded
                      : Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: labelColor,
                ),
                SizedBox(width: 6),
                Text(
                  labelText,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          //Card body Text
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  bodyText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),

          //Edit /Delete buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _iconBtn(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF2563EB),
                  tooltip: 'Edit',
                  onTap: () => _editCard(card),
                ),
                const SizedBox(width: 8),
                _iconBtn(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red,
                  tooltip: 'Delete',
                  onTap: () => _deleteCard(card.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //Small icon button helper
  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  //Show/hide answer button
  Widget _buildShowAnswerButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _toggleAnswer,
          icon: Icon(
            _showAnswer
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            size: 20,
          ),
          label: Text(
            _showAnswer ? 'Hide Answer' : 'Show Answer',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _showAnswer
                ? const Color(0xFF16A34A)
                : const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  //Prev/Next Navigation
  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cards.length > 1 ? _goPrev : null,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _cards.length > 1 ? _goNext : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              label: const Text('Next'),
              iconAlignment: IconAlignment.end,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
