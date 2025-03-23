import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../widgets/time_counter.dart';
import '../widgets/add_note_form.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final habit = habitProvider.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );
    
    final currentStreak = habitProvider.calculateStreak(habit);
    final category = defaultCategories.firstWhere(
      (cat) => cat.id == habit.category,
      orElse: () => defaultCategories.last,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали привычки'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    category.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Начато: ${DateFormat.yMMMd().format(habit.startDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _confirmRelapse(context, habit),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Рецидив'),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timelapse,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Время без привычки',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TimeCounter(
                    startDate: habit.lastRelapse ?? habit.startDate,
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.book),
                text: 'Журнал',
              ),
              Tab(
                icon: Icon(Icons.pie_chart),
                text: 'Статистика',
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                text: 'История',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJournalTab(context, habit),
                _buildStatsTab(context, habit, currentStreak),
                _buildHistoryTab(context, habit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalTab(BuildContext context, Habit habit) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const AddNoteForm(),
          const SizedBox(height: 16),
          Expanded(
            child: habit.notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book,
                          size: 48,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Записей пока нет',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Добавьте первую запись о своих ощущениях',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: habit.notes.length,
                    itemBuilder: (context, index) {
                      final note = habit.notes[habit.notes.length - 1 - index];
                      return _buildNoteCard(context, note);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
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

    final moodColors = {
      Mood.great: Colors.green,
      Mood.good: Colors.blue,
      Mood.neutral: Colors.grey,
      Mood.bad: Colors.orange,
      Mood.terrible: Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().add_Hm().format(note.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                Chip(
                  label: Text(moodLabels[note.mood]!),
                  avatar: Text(moodEmojis[note.mood]!),
                  backgroundColor: moodColors[note.mood]!.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: moodColors[note.mood],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context, Habit habit, int currentStreak) {
    final progress = (currentStreak / habit.goalDays) * 100;
    final clampedProgress = progress.clamp(0.0, 100.0);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Прогресс к цели',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Цель: ${habit.goalDays} дней'),
                      Text('${clampedProgress.toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: clampedProgress / 100,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Статистика',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    context,
                    Icons.calendar_today,
                    'Текущая серия',
                    '$currentStreak дней',
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    Icons.star,
                    'Лучшая серия',
                    '${Math.max(currentStreak, habit.longestStreak)} дней',
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    Icons.refresh,
                    'Количество рецидивов',
                    '${habit.relapses.length}',
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    Icons.note,
                    'Записей в журнале',
                    '${habit.notes.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Достижения',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementsList(context, habit, currentStreak),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(BuildContext context, Habit habit, int currentStreak) {
    final maxStreak = Math.max(habit.longestStreak, currentStreak);
    final achievements = <Map<String, dynamic>>[];
    
    if (maxStreak >= 1) {
      achievements.add({
        'icon': Icons.trending_up,
        'title': '1 день без привычки',
        'description': 'Первый шаг к новой жизни'
      });
    }
    
    if (maxStreak >= 7) {
      achievements.add({
        'icon': Icons.local_fire_department,
        'title': '7 дней без привычки',
        'description': 'Целая неделя силы воли!'
      });
    }
    
    if (maxStreak >= 30) {
      achievements.add({
        'icon': Icons.emoji_events,
        'title': '30 дней без привычки',
        'description': 'Месяц новой жизни!'
      });
    }
    
    if (habit.relapses.length >= 1 && currentStreak >= 1) {
      achievements.add({
        'icon': Icons.restart_alt,
        'title': 'Новое начало',
        'description': 'Вы не сдались после рецидива'
      });
    }
    
    if (achievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Продолжайте и вы получите достижения!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(achievement['title'] as String),
          subtitle: Text(achievement['description'] as String),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, Habit habit) {
    final sortedRelapses = [...habit.relapses]..sort((a, b) => b.compareTo(a));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'История рецидивов',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sortedRelapses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 48,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет записей о рецидивах',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Так держать! Продолжайте в том же духе.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedRelapses.length,
                    itemBuilder: (context, index) {
                      final relapse = sortedRelapses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.restart_alt,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          title: Text('Рецидив'),
                          subtitle: Text(DateFormat.yMMMd().add_Hm().format(relapse)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmRelapse(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Записать рецидив'),
        content: const Text('Вы уверены, что хотите записать рецидив? Это обнулит ваш текущий счетчик.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false)
                  .recordRelapse(habit.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Рецидив записан. Не сдавайтесь!'),
                ),
              );
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}

class Math {
  static int max(int a, int b) {
    return a > b ? a : b;
  }
}
