class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String description;
  bool isBorrowed;
  String? borrowerName;
  DateTime? borrowedDate;
  DateTime? dueDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    this.isBorrowed = false,
    this.borrowerName,
    this.borrowedDate,
    this.dueDate,
  });
}

class BorrowHistory {
  final String bookTitle;
  final String borrowerName;
  final String action; // 'Borrowed' or 'Returned'
  final DateTime timestamp;
  final DateTime? dueDate;

  BorrowHistory({
    required this.bookTitle,
    required this.borrowerName,
    required this.action,
    required this.timestamp,
    this.dueDate,
  });
}

final List<Book> dummyBooks = [
  Book(
    id: 'B001',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    category: 'Software Engineering',
    description: 'A handbook of agile software craftsmanship and writing maintainable code.',
  ),
  Book(
    id: 'B002',
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt & David Thomas',
    category: 'Programming',
    description: 'Classic guide from journeyman to master software developer.',
    isBorrowed: true,
    borrowerName: 'Juan Dela Cruz',
    borrowedDate: DateTime.now().subtract(const Duration(days: 2)),
    dueDate: DateTime.now().add(const Duration(days: 5)),
  ),
  Book(
    id: 'B003',
    title: 'Design Patterns',
    author: 'Erich Gamma et al.',
    category: 'Architecture',
    description: 'Elements of reusable object-oriented software design.',
  ),
  Book(
    id: 'B004',
    title: 'Flutter Apprentice',
    author: 'Michael Katz et al.',
    category: 'Mobile Development',
    description: 'Learn to build cross-platform mobile apps using Flutter and Dart.',
  ),
  Book(
    id: 'B005',
    title: 'Introduction to Algorithms',
    author: 'Thomas H. Cormen',
    category: 'Computer Science',
    description: 'Comprehensive textbook covering data structures and algorithms.',
  ),
  Book(
    id: 'B006',
    title: 'Database System Concepts',
    author: 'Abraham Silberschatz',
    category: 'Database',
    description: 'Foundational concepts of relational databases, SQL, and system architecture.',
  ),
  Book(
    id: 'B007',
    title: 'Artificial Intelligence: A Modern Approach',
    author: 'Stuart Russell & Peter Norvig',
    category: 'AI & Data Science',
    description: 'Standard guide to intelligent agents, machine learning, and robotics.',
  ),
  Book(
    id: 'B008',
    title: 'Computer Networking: A Top-Down Approach',
    author: 'James Kurose & Keith Ross',
    category: 'Networking',
    description: 'Explores internet protocols, application layers, and network security.',
  ),
  Book(
    id: 'B009',
    title: 'Operating System Concepts',
    author: 'Abraham Silberschatz',
    category: 'Systems',
    description: 'Covers processes, memory management, threads, and storage systems.',
  ),
  Book(
    id: 'B010',
    title: 'Refactoring',
    author: 'Martin Fowler',
    category: 'Software Engineering',
    description: 'Improving the design of existing code safely and effectively.',
  ),
];