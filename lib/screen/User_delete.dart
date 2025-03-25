import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class DeleteUserPage extends StatelessWidget {

  final String userId; // Pass user ID for deletion

Future<void> deleteUserAccount() async {
    final url = Uri.parse('http://103.247.19.200:5050/UserReg/delete/$userId');

        try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // Account deleted successfully
        print('Account deleted successfully');
        // Show success message or navigate to another screen
      } else {
        // Failed to delete the account
        print('Failed to delete the account: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while deleting account: $e');
    }
  }
  DeleteUserPage({required this.userId});

  void _deleteUser(BuildContext context) {
    // Call API or remove from database here
    print("User ID $userId deleted");

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account deleted successfully!")),
    );

    // Redirect or pop to previous screen
    Navigator.pop(context);
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              _deleteUser(context);
            },
            child: Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delete Account")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _confirmDeletion(context),
          child: Text("Delete My Account"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ),
    );
  }
}
