import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subscription_tracker/Auth_pages/signup_page.dart';
import 'package:subscription_tracker/pages/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _supabaseClient = Supabase.instance.client.auth;

  Future<void> _logIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields.")),
      );
      return;
    }
    try {
      final response = await _supabaseClient.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Logged In successfully.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } on AuthException catch (e) {
      // Supabase specific error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      // Any other error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  SizedBox(height: 100),

                  Text(
                    'Tracky',
                    style: GoogleFonts.sansita(
                      fontWeight: FontWeight.bold,
                      fontSize: 80,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'LOG IN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 7,
                      color: Color(0xFF919191),
                    ),
                  ),
                  SizedBox(height: 60),
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            labelText: 'Email',
                            hint: Text("Enter you email"),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),

                        SizedBox(height: 10),

                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            labelText: 'Password',
                            hint: Text("Enter your password"),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),

                        SizedBox(height: 30),

                        ElevatedButton(
                          style: ButtonStyle(
                            minimumSize: WidgetStatePropertyAll(
                              Size(double.infinity, 40),
                            ),
                            backgroundColor: WidgetStatePropertyAll(
                              Color(0xFF2E3440),
                            ),
                          ),
                          onPressed: () {
                            _logIn();
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Create a new account.",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
