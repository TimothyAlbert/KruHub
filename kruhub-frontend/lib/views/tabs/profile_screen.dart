import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String role;
  const ProfileScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ID Card[cite: 5]
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')), //[cite: 5]
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Timothy Albert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), //[cite: 5]
                        Text('Production Lead', style: TextStyle(color: Colors.grey, fontSize: 14)), //[cite: 5]
                      ],
                    ),
                  ),
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 16)), //[cite: 5]
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your ID', style: TextStyle(color: Colors.grey, fontSize: 10)), //[cite: 5]
                        Text('KRU-U-8F3K2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)), //[cite: 5]
                      ],
                    ),
                    Row(children: [Icon(Icons.copy, size: 16, color: Colors.grey), SizedBox(width: 4), Text('Copy', style: TextStyle(color: Colors.white))]), //[cite: 5]
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Team Management Buttons[cite: 6]
        const Text('Team', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), //[cite: 6]
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigasi ke Layar Pembuatan Tim Khusus (Full Screen)
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTeamScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white)), //[cite: 6]
                      const SizedBox(height: 16),
                      const Text('Create a Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), //[cite: 6]
                      const SizedBox(height: 4),
                      const Text('Start a new crew and invite members', style: TextStyle(color: Colors.grey, fontSize: 10)), //[cite: 6]
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.group_add_outlined, color: Colors.white)), //[cite: 6]
                    const SizedBox(height: 16),
                    const Text('Join a Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), //[cite: 6]
                    const SizedBox(height: 4),
                    const Text('Enter a team ID to join a crew', style: TextStyle(color: Colors.grey, fontSize: 10)), //[cite: 6]
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}