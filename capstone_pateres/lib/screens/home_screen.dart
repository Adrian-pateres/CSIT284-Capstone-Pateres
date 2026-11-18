import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';
import 'package:capstone_pateres/widgets/book_card.dart';
import 'package:capstone_pateres/screens/book_detail_screen.dart';
import 'package:capstone_pateres/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Book> _books = dummyBooks;
  final List<BorrowHistory> _history = [
    BorrowHistory(
      bookTitle: 'The Pragmatic Programmer',
      borrowerName: 'Juan Dela Cruz',
      action: 'Borrowed',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
  ];

  String _searchQuery = '';

  void _updateBookStatus(Book book, String borrowerName, bool borrow) {
    setState(() {
      if (borrow) {
        book.isBorrowed = true;
        book.borrowerName = borrowerName;
        book.borrowedDate = DateTime.now();
        book.dueDate = DateTime.now().add(const Duration(days: 7));
        _history.insert(
          0,
          BorrowHistory(
            bookTitle: book.title,
            borrowerName: borrowerName,
            action: 'Borrowed',
            timestamp: DateTime.now(),
            dueDate: book.dueDate,
          ),
        );
      } else {
        book.isBorrowed = false;
        book.borrowerName = null;
        book.borrowedDate = null;
        book.dueDate = null;
        _history.insert(
          0,
          BorrowHistory(
            bookTitle: book.title,
            borrowerName: borrowerName,
            action: 'Returned',
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _books.where((book) {
      final query = _searchQuery.toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Borrowing Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Borrow History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(historyList: _history),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search books by title, author, or category...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredBooks.isEmpty
                ? const Center(child: Text('No matching books found.'))
                : ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return BookCard(
                        book: book,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(
                                book: book,
                                onStatusChanged: _updateBookStatus,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}