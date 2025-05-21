import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // your page content here
      body: Center(child: Text('Main content')),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B6BC1), Color(0xFF3F3F8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home button with pill background
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF2DE5A0),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.home,
              size: 28,
              color: Colors.white,
            ),
          ),

          // Other icons
          _footerIcon(Icons.search),
          _footerIcon(Icons.add),
          _footerIcon(Icons.mail_outline),
          _footerIcon(Icons.person_outline),
        ],
      ),
    );
  }

  Widget _footerIcon(IconData icon) {
    return IconButton(
      icon: Icon(icon, size: 26, color: Colors.white),
      onPressed: () {
        // handle tap
      },
    );
  }
}
