import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _username = 'Farmer';
  String _recentDisease = 'No scans yet';
  String _recentConfidence = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('user_email') ?? 'Farmer';
    // Extract name from email (e.g., syeda@gmail.com -> Syeda)
    String name = email.split('@')[0];
    name = name[0].toUpperCase() + name.substring(1);

    List<String> history = prefs.getStringList('scan_history') ?? [];
    if (history.isNotEmpty) {
      var parts = history.first.split('|');
      setState(() {
        _recentDisease = parts[1];
        _recentConfidence = parts[2];
      });
    }

    setState(() {
      _username = name;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() => _imageBytes = bytes);

        var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/predict'));
        request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'leaf.jpg'));
        var response = await request.send();

        if (response.statusCode == 200) {
          var data = json.decode(await response.stream.bytesToString());
          String disease = data['disease'];
          double confidence = data['confidence'];

          final prefs = await SharedPreferences.getInstance();
          List<String> history = prefs.getStringList('scan_history') ?? [];
          String record = '${DateTime.now().toString().substring(0, 16)}|$disease|$confidence%';
          history.insert(0, record);
          await prefs.setStringList('scan_history', history);

          setState(() {
            _recentDisease = disease;
            _recentConfidence = '$confidence%';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Disease Detected: $disease'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
    } else if (index == 2) {
      _logout();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.person, color: Colors.green.shade700),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $_username!', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Let's keep your crops healthy!", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.grey.shade700),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Green Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Detect Crop Diseases with AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Upload a leaf image to get instant results & yield prediction.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload_file, color: Colors.green.shade700),
                                label: const Text('Upload Image', style: TextStyle(color: Colors.green.shade700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.eco, color: Colors.white, size: 40),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(Icons.camera_alt, 'Scan', _pickImage),
                      _buildQuickAction(Icons.history, 'History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
                      _buildQuickAction(Icons.tips_and_updates, 'Tips', () {}),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Recent Activity Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _recentDisease.contains('healthy') ? Colors.green.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _recentDisease.contains('healthy') ? Icons.check_circle : Icons.warning,
                            color: _recentDisease.contains('healthy') ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_recentDisease, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Tap to view details', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (_recentConfidence.isNotEmpty)
                          Text(_recentConfidence, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Helper widget for Quick Actions
  Widget _buildQuickAction(IconData icon, String label, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.green.shade700, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}