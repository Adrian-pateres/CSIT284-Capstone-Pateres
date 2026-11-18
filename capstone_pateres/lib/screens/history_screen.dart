import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';

class HistoryScreen extends StatelessWidget {
  final List<BorrowHistory> historyList;

  const HistoryScreen({super.key, required this.historyList});

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History'),
      ),
      body: historyList.isEmpty
          ? const Center(
              child: Text('No borrow or return history yet.'),
            )
          : ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final record = historyList[index];
                final isBorrow = record.action == 'Borrowed';
                return ListTile(
                  leading: Icon(
                    isBorrow ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isBorrow ? Colors.orange : Colors.green,
                  ),
                  title: Text(record.bookTitle),
                  subtitle: Text(
                    '${record.action} by ${record.borrowerName}\nDate: ${_formatDateTime(record.timestamp)}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}