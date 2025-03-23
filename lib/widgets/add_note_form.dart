import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../screens/habit_detail_screen.dart';

class AddNoteForm extends StatefulWidget {
  const AddNoteForm({Key? key}) : super(key: key);

  @override
  State<AddNoteForm> createState() => _AddNoteFormState();
}

class _AddNoteFormState extends State<AddNoteForm> {
  final _contentController = TextEditingController();
  Mood _selectedMood = Mood.neutral;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  final moodEmojis = {
    Mood.great: '😃',
    Mood.good: '🙂',
    Mood.neutral: '😐',
    Mood.bad: '😕',
    Mood.terrible: '😞',
  };

  final moodLabels = {
    Mood.great: 'Отлично',
    Mood.good: 'Хорошо',
    Mood.neutral: 'Нейтрально',
    Mood.bad: 'Плохо',
    Mood.terrible: 'Ужасно',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добавить запись',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Ваши мысли или ощущения',
                hintText: 'Как вы себя чувствуете сегодня? Что помогает справиться с желанием?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Настроение',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: Mood.values.map((mood) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedMood == mood
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedMood == mood
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          moodEmojis[mood]!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          moodLabels[mood]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _selectedMood == mood
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedMood == mood
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add),
                label: const Text('Добавить запись'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addNote() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите текст заметки'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final habitId = ModalRoute.of(context)!.settings.arguments as String? ??
        (context.findAncestorWidgetOfExactType<HabitDetailScreen>() as HabitDetailScreen).habit.id;
    
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      content: _contentController.text.trim(),
      mood: _selectedMood,
    );
    
    habitProvider.addNote(habitId, newNote);
    _contentController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заметка добавлена'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


