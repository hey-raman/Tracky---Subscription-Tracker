import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subscription_tracker/Auth_pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final _supabaseClient = Supabase.instance.client;
  User? user; // store user here
  List<Map<String, dynamic>> subscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserAndSubscriptions();
  }

  Future<void> _getUserAndSubscriptions() async {
    final session = _supabaseClient.auth.currentSession;

    if (session == null) {
      // not logged in
      setState(() => isLoading = false);
      return;
    }

    user = session.user;
    print('User ID: ${user?.id}');

    final response = await _supabaseClient
        .from('subscriptions')
        .select()
        .eq('user_id', user!.id);

    setState(() {
      subscriptions = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> addSubscription(
    String name,
    double price,
    DateTime renewDate,
  ) async {
    await _supabaseClient.from('subscriptions').insert({
      'user_id': _supabaseClient.auth.currentUser!.id,
      'name': name,
      'price': price,
      'renew_date': renewDate.toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _supabaseClient.auth.signOut();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("User Signed Out")));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
        title: Text(
          "Tracky",
          style: GoogleFonts.sansita(fontWeight: FontWeight.w600, fontSize: 30),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // change selected tab
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: _currentIndex == 0 ? HomeTab() : AnalyticsTab(),
      ),
    );
  }

  Widget HomeTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Spending Overview Card
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Color(0xFF5E81AC),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Overview',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 05),
                  Text(
                    _getTotalMonthlySpend(false),
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Till Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Add and Manage buttons
          Row(
            spacing: 20,
            children: [
              //Add Button
              Expanded(
                child: InkWell(
                  onTap: () {
                    final _SubNameController = TextEditingController();
                    final _SubPriceController = TextEditingController();
                    DateTime? _SubSelectedDate;

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddDialog(
                          _SubNameController,
                          _SubPriceController,
                          _SubSelectedDate,
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Ink(
                    padding: EdgeInsets.all(20),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        Icon(Icons.add, size: 30),
                        Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //Manage Button
            ],
          ),

          SizedBox(height: 50),

          Text(
            "Upcoming Renewals",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),

          SizedBox(height: 20),

          SubscriptionList(true),

          SizedBox(height: 20),

          Text(
            "Recent Renewals",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),

          SizedBox(height: 20),

          SubscriptionList(false),
        ],
      ),
    );
  }

  Widget AnalyticsTab() {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 40, top: 60, bottom: 40),
            child: monthlyLineChart(subscriptions),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    width: double.maxFinite,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getTotalMonthlySpend(true),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Monthly Spend',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    width: double.maxFinite,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          subscriptions.length.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Active Subscriptions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget SubscriptionList(bool showUpcomingOnly) {
    subscriptions.sort((a, b) {
      final dateA = DateTime.parse(a['renew_date']);
      final dateB = DateTime.parse(b['renew_date']);
      return dateA.compareTo(dateB);
    });
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : subscriptions.isEmpty
        ? Center(child: Text('Add your first subscription!'))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              DateTime renewDate = DateTime.parse(sub['renew_date']);
              DateTime today = DateTime.now();

              if (showUpcomingOnly
                  ? renewDate.isBefore(today)
                  : renewDate.isAfter(today)) {
                return const SizedBox.shrink(); // return empty widget instead of re-declaring
              }

              return PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'delete', child: Text("Delete")),
                  const PopupMenuItem(value: 'cancel', child: Text("Cancel")),
                ],

                onSelected: (value) async {
                  if (value == 'delete') {
                    await _supabaseClient
                        .from('subscriptions')
                        .delete()
                        .eq('id', sub['id']);
                    _getUserAndSubscriptions();
                  }
                },

                child: Container(
                  height: 115,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub['name'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              sub['renew_date'] != null
                                  ? (DateTime.tryParse(sub['renew_date']) !=
                                            null
                                        ? "${_getNextRenewalDate(sub['renew_date']).day}/"
                                              "${_getNextRenewalDate(sub['renew_date']).month}/"
                                              "${_getNextRenewalDate(sub['renew_date']).year}"
                                        : 'Invalid Date')
                                  : 'No Date',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${sub['price']?.toStringAsFixed(1) ?? '0.00'}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget AddDialog(SubNameController, SubPriceController, SubSelectedDate) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add Subscription',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: SubNameController,
                decoration: InputDecoration(
                  labelText: 'Subscription Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: SubPriceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    SubSelectedDate == null
                        ? "Pick Renewal Date"
                        : "${SubSelectedDate.day}/${SubSelectedDate.month}/${SubSelectedDate.year}",
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          SubSelectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xFF2E3440)),
              ),
              onPressed: () async {
                if (SubNameController.text.isNotEmpty &&
                    SubPriceController.text.isNotEmpty &&
                    SubSelectedDate != null) {
                  await addSubscription(
                    SubNameController.text,
                    double.parse(SubPriceController.text),
                    SubSelectedDate!,
                  );
                  Navigator.pop(context);
                  _getUserAndSubscriptions(); // refresh after insert
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  DateTime _getNextRenewalDate(String dateString) {
    DateTime renewDate = DateTime.parse(dateString);
    DateTime today = DateTime.now();

    while (renewDate.isBefore(today)) {
      renewDate = DateTime(renewDate.year, renewDate.month + 1, renewDate.day);
    }

    return DateTime(renewDate.year, renewDate.month, renewDate.day);
  }

  String _getTotalMonthlySpend(bool showMonthly) {
    DateTime today = DateTime.now();
    double total = 0.0;

    if (!showMonthly) {
      for (var sub in subscriptions) {
        DateTime renewDate = DateTime.parse(sub['renew_date']);
        if (renewDate.isBefore(today)) {
          total += (sub['price'] ?? 0);
        }
      }
      return "₹ ${total.toStringAsFixed(1)}";
    } else {
      for (var sub in subscriptions) {
        DateTime renewDate = _getNextRenewalDate(sub['renew_date']);
        if (renewDate.month != today.month || renewDate.year != today.year) {
          continue;
        }
        total += (sub['price'] ?? 0);
      }
      return "₹ ${total.toStringAsFixed(1)}";
    }
  }

  Map<int, double> getMonthlySpending(
    List<Map<String, dynamic>> subscriptions,
  ) {
    Map<int, double> monthlyTotals = {};

    DateTime today = DateTime.now();

    for (var sub in subscriptions) {
      DateTime renewDate = DateTime.parse(sub['renew_date']);
      DateTime nextRenewal = renewDate;

      // roll forward to current year if needed
      while (nextRenewal.isBefore(DateTime(today.year, 1, 1))) {
        nextRenewal = DateTime(
          nextRenewal.year + 1,
          nextRenewal.month,
          nextRenewal.day,
        );
      }

      int month = nextRenewal.month;

      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + (sub['price'] ?? 0);
    }

    // Ensure all months are present
    for (int i = 1; i <= 12; i++) {
      monthlyTotals[i] = monthlyTotals[i] ?? 0.0;
    }

    return monthlyTotals;
  }

  Widget monthlyLineChart(List<Map<String, dynamic>> subscriptions) {
    final monthlyData = getMonthlySpending(subscriptions);

    List<FlSpot> spots = [];
    for (int month = 1; month <= 12; month++) {
      spots.add(FlSpot(month.toDouble(), monthlyData[month]!));
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    '',
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  return Text(months[value.toInt()]);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 60),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 3,
              color: Colors.blue,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
