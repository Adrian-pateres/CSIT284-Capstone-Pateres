import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final Future<void> Function(Book, String, bool) onStatusChanged;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.onStatusChanged,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final TextEditingController _borrowerController = TextEditingController();
  bool _isSaving = false;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _handleBorrow() async {
    final name = _borrowerController.text.trim().isEmpty
        ? 'Student Borrower'
        : _borrowerController.text.trim();

    setState(() => _isSaving = true);
    try {
      await widget.onStatusChanged(widget.book, name, true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borrowed "${widget.book.title}" successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving to Firebase: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleReturn() async {
    final previousBorrower = widget.book.borrowerName ?? 'Student Borrower';

    setState(() => _isSaving = true);
    try {
      await widget.onStatusChanged(widget.book, previousBorrower, false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Returned "${widget.book.title}" successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating Firebase: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _borrowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Author: ${book.author}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Chip(label: Text(book.category)),
            const SizedBox(height: 16),
            Text(
              book.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  book.isBorrowed ? 'Borrowed' : 'Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: book.isBorrowed ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (book.isBorrowed) ...[
              Text('Borrowed by: ${book.borrowerName ?? "N/A"}'),
              const SizedBox(height: 4),
              if (book.borrowedDate != null)
                Text('Date Borrowed: ${_formatDate(book.borrowedDate!)}'),
              const SizedBox(height: 4),
              if (book.dueDate != null)
                Text(
                  'Due Date: ${_formatDate(book.dueDate!)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _handleReturn,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.assignment_return),
                  label: Text(_isSaving ? 'Updating...' : 'Return Book'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _borrowerController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Student Name or ID',
                  border: OutlineInputBorder(),
                  hintText: 'Enter borrower name/ID',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _handleBorrow,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.book),
                  label: Text(
                      _isSaving ? 'Saving...' : 'Borrow Book (7 Days Due)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}