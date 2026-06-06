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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEditing
                      ? Icons.edit_road_rounded
                      : Icons.add_circle_rounded,
                  color: const Color(0xFF2563EB),
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  isEditing ? 'Edit Card' : 'Add New Card',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            //Question Field
            Text(
              'Question',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your question here...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            //Answer Field
            Text(
              'Answer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _answerController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter Your answer here...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
                ),
              ),
            ),

            SizedBox(height: 24),
            //Cancel/save Buttons
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel',style: TextStyle(color: Colors.grey),),
                ),

                SizedBox(width: 10,),
                ElevatedButton.icon(onPressed: _save,
                icon: Icon(Icons.save_rounded,size: 18,),
                label: Text('Save Card'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12)
                ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
