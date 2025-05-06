import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DayDream'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // User Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple.shade100,
                      backgroundImage:
                          user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                      child:
                          user?.photoURL == null
                              ? Text(
                                _getInitials(
                                  user?.displayName ?? user?.email ?? 'User',
                                ),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              )
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // User Name
                    Text(
                      user?.displayName ?? 'Dreamer',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User Email
                    Text(
                      user?.email ?? 'No email provided',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // User Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Dreams', '12'),
                        _buildStatColumn('Followers', '248'),
                        _buildStatColumn('Following', '114'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            Text(
              'Recent Activity',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Placeholder for recent activity
            _buildActivityItem(
              title: 'Created a new dream journal',
              time: '2 hours ago',
              icon: Icons.book,
              color: Colors.blue,
            ),
            _buildActivityItem(
              title: 'Updated profile information',
              time: 'Yesterday',
              icon: Icons.person,
              color: Colors.green,
            ),
            _buildActivityItem(
              title: 'Completed dream analysis',
              time: '3 days ago',
              icon: Icons.psychology,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get initials from name or email
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }

  // Helper method to build stat columns
  Widget _buildStatColumn(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Helper method to build activity items
  Widget _buildActivityItem({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(time, style: GoogleFonts.dmSans(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
