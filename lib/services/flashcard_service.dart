import 'package:flashcard_quiz_app/model/flashcard_model.dart';
import 'package:flutter/material.dart';

class FlashcardService {
  final List<FlashCard> _cards = [
    FlashCard(
      id: '1',
      question: 'What is the capital of Bangladesh',
      answer: 'Dhaka',
    ),

    FlashCard(id: '2', question: 'What is 2+2?', answer: '4'),

    FlashCard(id: '3', question: 'What color is the sky?', answer: 'Blue'),

    FlashCard(id: '4', question: 'What planet do we live on?', answer: 'Earth'),

    FlashCard(id: '5', question: 'How many days are in a week?', answer: '7'),
  ];

  List<FlashCard> get allCards => List.unmodifiable(_cards);

  //add new card

  void addCard({required String question, required String answer}) {
    final newCard = FlashCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      answer: answer,
    );
    _cards.add(newCard);
  }

  //update Card
  void updateCard({
    required String id,
    required String question,
    required String answer,
  }) {
    //search position
    final index = _cards.indexWhere((card) => card.id == id);

    //if card exits
    if (index != -1) {
      //update question
      _cards[index].question = question;
      //update answer
      _cards[index].answer = answer;
    }
  }

  void deleteCard(String id) {
    _cards.removeWhere(
        (card)=>card.id==id,
    );
  }
}
