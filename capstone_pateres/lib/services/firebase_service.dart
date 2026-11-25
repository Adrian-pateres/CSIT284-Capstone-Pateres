import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:capstone_pateres/models/book.dart';

class FirebaseService {
  static const String baseUrl = 'https://capstone-book-tracker-default-rtdb.asia-southeast1.firebasedatabase.app/';

  Future<List<Book>> fetchBooks() async {
    final url = Uri.parse('$baseUrl/books.json');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load books from Firebase');
    }

    if (response.body == 'null') {
      await _seedInitialData();
      return List<Book>.from(dummyBooks);
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<Book> loadedBooks = [];

    data.forEach((key, value) {
      loadedBooks.add(Book.fromJson(key, Map<String, dynamic>.from(value)));
    });

    loadedBooks.sort((a, b) => a.id.compareTo(b.id));
    return loadedBooks;
  }

  Future<void> _seedInitialData() async {
    final booksUrl = Uri.parse('$baseUrl/books.json');
    final Map<String, dynamic> booksPayload = {};

    for (final book in dummyBooks) {
      booksPayload[book.id] = book.toJson();
    }

    await http.put(booksUrl, body: json.encode(booksPayload));

    final initialHistory = BorrowHistory(
      bookTitle: 'The Pragmatic Programmer',
      borrowerName: 'Juan Dela Cruz',
      action: 'Borrowed',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
    );

    final historyUrl = Uri.parse('$baseUrl/history.json');
    await http.post(historyUrl, body: json.encode(initialHistory.toJson()));
  }

  Future<void> updateBookStatus(
      Book book, String borrowerName, bool borrow) async {
    final bookUrl = Uri.parse('$baseUrl/books/${book.id}.json');
    final historyUrl = Uri.parse('$baseUrl/history.json');
    final now = DateTime.now();

    if (borrow) {
      final due = now.add(const Duration(days: 7));
      final patchResponse = await http.patch(
        bookUrl,
        body: json.encode({
          'isBorrowed': true,
          'borrowerName': borrowerName,
          'borrowedDate': now.toIso8601String(),
          'dueDate': due.toIso8601String(),
        }),
      );

      if (patchResponse.statusCode != 200) {
        throw Exception('Failed to update book status');
      }

      final record = BorrowHistory(
        bookTitle: book.title,
        borrowerName: borrowerName,
        action: 'Borrowed',
        timestamp: now,
        dueDate: due,
      );

      await http.post(historyUrl, body: json.encode(record.toJson()));
    } else {
      final patchResponse = await http.patch(
        bookUrl,
        body: json.encode({
          'isBorrowed': false,
          'borrowerName': null,
          'borrowedDate': null,
          'dueDate': null,
        }),
      );

      if (patchResponse.statusCode != 200) {
        throw Exception('Failed to return book');
      }

      final record = BorrowHistory(
        bookTitle: book.title,
        borrowerName: borrowerName,
        action: 'Returned',
        timestamp: now,
      );

      await http.post(historyUrl, body: json.encode(record.toJson()));
    }
  }

  Future<List<BorrowHistory>> fetchHistory() async {
    final url = Uri.parse('$baseUrl/history.json');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load history');
    }

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<BorrowHistory> loadedHistory = [];

    data.forEach((key, value) {
      loadedHistory
          .add(BorrowHistory.fromJson(key, Map<String, dynamic>.from(value)));
    });

    loadedHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return loadedHistory;
  }

  Future<void> clearHistory() async {
    final url = Uri.parse('$baseUrl/history.json');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to clear history');
    }
  }
}