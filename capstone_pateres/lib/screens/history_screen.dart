import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';

class HistoryScreen extends StatelessWidget {
  final List<BorrowHistory> historyList;

  const HistoryScreen({super.key, required this.historyList});

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final record = historyList[index];
                final isBorrow = record.action == 'Borrowed';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isBorrow
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      child: Icon(
                        isBorrow ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isBorrow
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                    title: Text(
                      record.bookTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Borrower: ${record.borrowerName}'),
                        Text('Logged: ${_formatDateTime(record.timestamp)}'),
                        if (isBorrow && record.dueDate != null)
                          Text(
                            'Due Date: ${_formatDate(record.dueDate!)}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        record.action,
                        style: TextStyle(
                          fontSize: 12,
                          color: isBorrow
                              ? Colors.orange.shade900
                              : Colors.green.shade900,
                        ),
                      ),
                      backgroundColor: isBorrow
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                    ),
                  ),
                );
              },
            ),
    );
  }
}