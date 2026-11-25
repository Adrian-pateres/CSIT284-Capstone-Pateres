import 'package:flutter/material.dart';
import 'package:capstone_pateres/models/book.dart';
import 'package:capstone_pateres/services/firebase_service.dart';
import 'package:capstone_pateres/widgets/book_card.dart';
import 'package:capstone_pateres/screens/book_detail_screen.dart';
import 'package:capstone_pateres/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Book> _books = [];
  List<BorrowHistory> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _firebaseService.fetchBooks();
      final history = await _firebaseService.fetchHistory();
      if (!mounted) return;
      setState(() {
        _books = books;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to connect to Firebase: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBookStatus(
      Book book, String borrowerName, bool borrow) async {
    await _firebaseService.updateBookStatus(book, borrowerName, borrow);
    final updatedBooks = await _firebaseService.fetchBooks();
    final updatedHistory = await _firebaseService.fetchHistory();

    if (!mounted) return;
    setState(() {
      _books = updatedBooks;
      _history = updatedHistory;
      final refreshedBook = _books.firstWhere((b) => b.id == book.id);
      book.isBorrowed = refreshedBook.isBorrowed;
      book.borrowerName = refreshedBook.borrowerName;
      book.borrowedDate = refreshedBook.borrowedDate;
      book.dueDate = refreshedBook.dueDate;
    });
  }

  Future<void> _clearHistory() async {
    await _firebaseService.clearHistory();
    if (!mounted) return;
    setState(() {
      _history = [];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _books.where((b) => !b.isBorrowed).length;
    final borrowedCount = _books.where((b) => b.isBorrowed).length;

    final filteredBooks = _books.where((book) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);

      if (_selectedFilter == 'Available') {
        return matchesSearch && !book.isBorrowed;
      } else if (_selectedFilter == 'Borrowed') {
        return matchesSearch && book.isBorrowed;
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Borrowing Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync with Firebase',
            onPressed: _isLoading ? null : _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Borrow History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(
                    historyList: _history,
                    onClearHistory: _clearHistory,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search books by title, author, or category...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text('All (${_books.length})'),
                            selected: _selectedFilter == 'All',
                            onSelected: (_) =>
                                setState(() => _selectedFilter = 'All'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('Available ($availableCount)'),
                            selected: _selectedFilter == 'Available',
                            onSelected: (_) =>
                                setState(() => _selectedFilter = 'Available'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('Borrowed ($borrowedCount)'),
                            selected: _selectedFilter == 'Borrowed',
                            onSelected: (_) =>
                                setState(() => _selectedFilter = 'Borrowed'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: filteredBooks.isEmpty
                          ? const Center(
                              child: Text('No matching books found.'))
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