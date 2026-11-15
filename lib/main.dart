import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

// ============================================================
// EXPENSE MODEL
// ============================================================

class Expense {
  final String id;
  String title;
  double amount;
  String category;
  DateTime date;
  String note;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });
}

// ============================================================
// APP
// ============================================================

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F6FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      showMessage(context, 'Enter a valid email address.');
      return;
    }

    if (password.length < 4) {
      showMessage(context, 'Password must contain at least 4 characters.');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseHomeScreen(
          userEmail: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 75,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Expense Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your money smarter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                FilledButton(
                  onPressed: login,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Demo login: enter any valid email and a password of at least 4 characters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN HOME SCREEN
// ============================================================

class ExpenseHomeScreen extends StatefulWidget {
  final String userEmail;

  const ExpenseHomeScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<ExpenseHomeScreen> createState() => _ExpenseHomeScreenState();
}

class _ExpenseHomeScreenState extends State<ExpenseHomeScreen> {
  int selectedIndex = 0;

  String searchQuery = '';
  String selectedFilter = 'All';
  String userName = 'User';

  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  final double monthlyIncome = 30000;

  final List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Education',
    'Entertainment',
    'Health',
    'Bills',
    'Other',
  ];

  late List<Expense> expenses;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    expenses = [
      Expense(
        id: '1',
        title: 'Lunch',
        amount: 250,
        category: 'Food',
        date: now,
        note: 'Lunch with friends',
      ),
      Expense(
        id: '2',
        title: 'Bus ticket',
        amount: 100,
        category: 'Travel',
        date: now,
      ),
      Expense(
        id: '3',
        title: 'Clothes',
        amount: 1200,
        category: 'Shopping',
        date: now,
      ),
      Expense(
        id: '4',
        title: 'Books',
        amount: 500,
        category: 'Education',
        date: now,
      ),
    ];
  }

  double get totalExpense {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  double get balance => monthlyIncome - totalExpense;

  double get monthlyExpense {
    final now = DateTime.now();

    return expenses
        .where(
          (expense) =>
              expense.date.year == now.year &&
              expense.date.month == now.month,
        )
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> get filteredExpenses {
    return expenses.where((expense) {
      final matchesSearch =
          expense.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          expense.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          expense.note.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory =
          selectedFilter == 'All' ||
          expense.category == selectedFilter;

      return matchesSearch && matchesCategory;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> openExpenseForm({Expense? expense}) async {
    final result = await showDialog<Expense>(
      context: context,
      builder: (_) => ExpenseFormDialog(
        categories: categories,
        expense: expense,
      ),
    );

    if (result == null) return;

    setState(() {
      if (expense == null) {
        expenses.insert(0, result);
      } else {
        final index = expenses.indexWhere(
          (item) => item.id == expense.id,
        );

        if (index != -1) {
          expenses[index] = result;
        }
      }
    });

    showMessage(
      context,
      expense == null
          ? 'Expense added successfully.'
          : 'Expense updated successfully.',
    );
  }

  Future<void> deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text(
          'Are you sure you want to delete "${expense.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        expenses.removeWhere((item) => item.id == expense.id);
      });

      showMessage(context, 'Expense deleted.');
    }
  }

  void showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Expense Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            detailRow('Title', expense.title),
            detailRow('Amount', money(expense.amount)),
            detailRow('Category', expense.category),
            detailRow('Date', dateText(expense.date)),
            detailRow(
              'Note',
              expense.note.isEmpty ? 'No note' : expense.note,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              openExpenseForm(expense: expense);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String get pageTitle {
    const titles = [
      'Dashboard',
      'Expense History',
      'Categories',
      'Monthly Summary',
      'Profile',
    ];

    return titles[selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboardPage(),
      expenseHistoryPage(),
      categoriesPage(),
      summaryPage(),
      profilePage(),
    ];

    return Theme(
      data: darkModeEnabled
          ? ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
            )
          : ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F6FC),
            ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          actions: [
            if (selectedIndex == 0)
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  showMessage(context, 'You are all caught up!');
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
          ],
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => openExpenseForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Summary',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DASHBOARD
  // ==========================================================

  Widget dashboardPage() {
    final recent = [...expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Welcome back!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Here is your spending overview.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.deepPurple,
                Color(0xFF7650C9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 14),
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                money(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: statCard(
                'Monthly Income',
                money(monthlyIncome),
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: statCard(
                'Total Expenses',
                money(totalExpense),
                Icons.trending_down,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => selectedIndex = 1);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        if (recent.isEmpty)
          const EmptyState(
            message: 'No expenses added yet.',
            icon: Icons.receipt_long,
          )
        else
          ...recent.take(5).map(expenseCard),
      ],
    );
  }

  Widget statCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EXPENSE HISTORY, SEARCH AND FILTER
  // ==========================================================

  Widget expenseHistoryPage() {
    final filtered = filteredExpenses;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search expenses...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
            ),
          ),
        ),
        SizedBox(
          height: 55,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              filterChip('All'),
              ...categories.map(filterChip),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  message: 'No matching expenses found.',
                  icon: Icons.search_off,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return expenseCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget filterChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(category),
        selected: selectedFilter == category,
        onSelected: (_) {
          setState(() {
            selectedFilter = category;
          });
        },
      ),
    );
  }

  // ==========================================================
  // EXPENSE CARD
  // ==========================================================

  Widget expenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      child: ListTile(
        onTap: () => showExpenseDetails(expense),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withValues(alpha: 0.10),
          child: Icon(
            categoryIcon(expense.category),
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${expense.title} • ${dateText(expense.date)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-${money(expense.amount)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  openExpenseForm(expense: expense);
                } else if (value == 'delete') {
                  deleteExpense(expense);
                } else if (value == 'details') {
                  showExpenseDetails(expense);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'details',
                  child: Text('View details'),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CATEGORIES
  // ==========================================================

  Widget categoriesPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'See where your money goes.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...categories.map((category) {
          final amount = expenses
              .where((e) => e.category == category)
              .fold(0.0, (sum, e) => sum + e.amount);

          final percentage =
              totalExpense == 0 ? 0.0 : amount / totalExpense;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.deepPurple.withValues(alpha: 0.10),
                        child: Icon(
                          categoryIcon(category),
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        money(amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: percentage.clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================================
  // MONTHLY SUMMARY
  // ==========================================================

  Widget summaryPage() {
    final now = DateTime.now();

    final monthExpenses = expenses.where((expense) {
      return expense.date.month == now.month &&
          expense.date.year == now.year;
    }).toList();

    final monthTotal = monthExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    final monthBalance = monthlyIncome - monthTotal;

    final highestCategory = categories.isEmpty
        ? 'None'
        : categories.reduce((a, b) {
            final amountA = categoryTotal(a);
            final amountB = categoryTotal(b);
            return amountA >= amountB ? a : b;
          });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${monthName(now.month)} ${now.year}',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        statCard(
          'Monthly Income',
          money(monthlyIncome),
          Icons.trending_up,
          Colors.green,
        ),
        const SizedBox(height: 12),
        statCard(
          'Monthly Spending',
          money(monthTotal),
          Icons.trending_down,
          Colors.red,
        ),
        const SizedBox(height: 12),
        statCard(
          'Remaining Balance',
          money(monthBalance),
          Icons.account_balance_wallet,
          Colors.deepPurple,
        ),
        const SizedBox(height: 25),
        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ...categories.map((category) {
          final amount = monthExpenses
              .where((e) => e.category == category)
              .fold(0.0, (sum, e) => sum + e.amount);

          if (amount == 0) return const SizedBox.shrink();

          final percentage =
              monthTotal == 0 ? 0.0 : amount / monthTotal;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category),
                    Text(money(amount)),
                  ],
                ),
                const SizedBox(height: 7),
                LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 15),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.emoji_events,
              color: Colors.deepPurple,
            ),
            title: const Text('Top Spending Category'),
            subtitle: Text(highestCategory),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Number of Expenses'),
            trailing: Text('${monthExpenses.length}'),
          ),
        ),
      ],
    );
  }

  double categoryTotal(String category) {
    return expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // ==========================================================
  // PROFILE AND SETTINGS
  // ==========================================================

  Widget profilePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 15),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Colors.deepPurple,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 55,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.userEmail,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            subtitle: const Text('Change your display name'),
            trailing: const Icon(Icons.chevron_right),
            onTap: editProfile,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification preference'),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Change application appearance'),
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Expense Tracker'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Expense Tracker',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Flutter Internship Week 4 Project',
              );
            },
          ),
        ),
        const SizedBox(height: 25),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Future<void> editProfile() async {
    final controller = TextEditingController(text: userName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null && result.isNotEmpty) {
      setState(() {
        userName = result;
      });

      showMessage(context, 'Profile updated.');
    }
  }
}

// ============================================================
// ADD AND EDIT EXPENSE FORM
// ============================================================

class ExpenseFormDialog extends StatefulWidget {
  final List<String> categories;
  final Expense? expense;

  const ExpenseFormDialog({
    super.key,
    required this.categories,
    this.expense,
  });

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController noteController;

  late String selectedCategory;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    titleController = TextEditingController(
      text: expense?.title ?? '',
    );

    amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );

    noteController = TextEditingController(
      text: expense?.note ?? '',
    );

    selectedCategory = expense?.category ?? widget.categories.first;
    selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    final amount = double.parse(amountController.text.trim());

    final expense = Expense(
      id: widget.expense?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
      note: noteController.text.trim(),
    );

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.expense == null ? 'Add Expense' : 'Edit Expense',
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Expense Title',
                    hintText: 'Example: Dinner',
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an expense title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount greater than zero.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: chooseDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(dateText(selectedDate)),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: save,
          child: const Text('Save Expense'),
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMON HELPERS
// ============================================================

String money(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

String dateText(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[month - 1];
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Travel':
      return Icons.directions_bus;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Education':
      return Icons.menu_book;
    case 'Entertainment':
      return Icons.movie;
    case 'Health':
      return Icons.medical_services;
    case 'Bills':
      return Icons.receipt_long;
    default:
      return Icons.receipt;
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}