import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';

class HistoryScreen extends StatefulWidget {
  final List<BorrowHistory> historyList;
  final Future<void> Function() onClearHistory;

  const HistoryScreen({
    super.key,
    required this.historyList,
    required this.onClearHistory,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isClearing = false;

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('Are you sure you want to delete all history records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearing = true);
    try {
      await widget.onClearHistory();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared from Firebase.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear history: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing History'),
        actions: [
          if (widget.historyList.isNotEmpty)
            IconButton(
              icon: _isClearing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: 'Clear History',
              onPressed: _isClearing ? null : _confirmClear,
            ),
        ],
      ),
      body: widget.historyList.isEmpty
          ? const Center(
              child: Text('No borrow or return history yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.historyList.length,
              itemBuilder: (context, index) {
                final record = widget.historyList[index];
                final isBorrow = record.action == 'Borrowed';
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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