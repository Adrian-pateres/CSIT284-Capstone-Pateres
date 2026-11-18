import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: book.isBorrowed
              ? Colors.red.shade100
              : Colors.green.shade100,
          child: Icon(
            book.isBorrowed ? Icons.book_outlined : Icons.menu_book,
            color: book.isBorrowed ? Colors.red.shade800 : Colors.green.shade800,
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${book.author} • ${book.category}'),
            if (book.isBorrowed && book.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Due Date: ${_formatDate(book.dueDate!)} (By: ${book.borrowerName})',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            book.isBorrowed ? 'Borrowed' : 'Available',
            style: TextStyle(
              fontSize: 12,
              color: book.isBorrowed ? Colors.red.shade900 : Colors.green.shade900,
            ),
          ),
          backgroundColor: book.isBorrowed
              ? Colors.red.shade50
              : Colors.green.shade50,
        ),
      ),
    );
  }
}