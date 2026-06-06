import 'package:flutter/material.dart';
import 'package:flashcard_quiz_app/model/flashcard_model.dart';

class CardDialog extends StatefulWidget {
  final FlashCard? card;
  const CardDialog({super.key, this.card});

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _questionController = TextEditingController(
      text: widget.card?.question ?? '',
    );
    _answerController = TextEditingController(text: widget.card?.answer ?? '');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    final q = _questionController.text.trim();
    final a = _answerController.text.trim();
    //don't save if either field is empty
    if (q.isEmpty || a.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in both fields!')));
      return;
    }
    //return the data to the calling screen
    Navigator.of(context).pop({'question': q, 'answer': a});
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.card != null;
    return Dialog(
      child: Column(
        children: [

        ],
      ),
    );
  }
}
