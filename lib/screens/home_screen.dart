import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/add_habit_dialog.dart';
import '../models/habit.dart';
import 'habit_detail_screen.dart';
import '../theme/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final habits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Трекер привычек',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.setThemeMode(
                themeProvider.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Отслеживайте свой прогресс, фиксируйте мысли и чувства, достигайте новых целей и избавляйтесь от зависимостей',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          habits.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет активных привычек',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажмите "Добавить привычку", чтобы начать отслеживать свой прогресс',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      final currentStreak = habitProvider.calculateStreak(habit);
                      final category = defaultCategories.firstWhere(
                        (cat) => cat.id == habit.category,
                        orElse: () => defaultCategories.last,
                      );
                      
                      return HabitCard(
                        habit: habit,
                        currentStreak: currentStreak,
                        category: category,
                        onView: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitDetailScreen(habit: habit),
                            ),
                          );
                        },
                        onRelapse: () {
                          _showRelapseConfirmDialog(context, habit);
                        },
                        onDelete: () {
                          _showDeleteConfirmDialog(context, habit);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить привычку'),
      ),
    );
  }

  Future<void> _showAddHabitDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );
  }

  Future<void> _showRelapseConfirmDialog(BuildContext context, Habit habit) async {
    return showDialog(
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

  Future<void> _showDeleteConfirmDialog(BuildContext context, Habit habit) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить привычку'),
        content: const Text('Вы уверены, что хотите удалить эту привычку? Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HabitProvider>(context, listen: false)
                  .deleteHabit(habit.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Привычка удалена'),
                ),
              );
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
