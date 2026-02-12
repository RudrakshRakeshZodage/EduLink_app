import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'Math', 'Code', 'English', 'Science'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isStudent = appState.userType == 'student';

    final items = isStudent
        ? [
            {
              'title': 'Calculus Notes',
              'author': 'Kalyani M.',
              'rating': 4.9,
              'price': '₹250',
              'tags': ['Math', 'Notes']
            },
            {
              'title': 'DSA Guide',
              'author': 'Arjun K.',
              'rating': 4.8,
              'price': '₹300',
              'tags': ['Code', 'CS']
            },
            {
              'title': 'Organic Chem',
              'author': 'Priya S.',
              'rating': 4.7,
              'price': '₹200',
              'tags': ['Science']
            },
          ]
        : [
            {
              'title': 'Help with Integration',
              'author': 'Tanisha T.',
              'rating': 4.8,
              'price': '₹300',
              'tags': ['Math', 'Urgent']
            },
            {
              'title': 'Java OOP Help',
              'author': 'Rohit K.',
              'rating': 4.7,
              'price': '₹250',
              'tags': ['Code']
            },
          ];

    final groups = [
      {'title': 'JEE Physics Group', 'members': 12, 'subject': 'Physics'},
      {'title': 'CA Accounts Circle', 'members': 8, 'subject': 'Accounts'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => appState.setScreen('home'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isStudent ? 'Find Tutors' : 'Find Students',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.filter_list),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((filter) {
                        final isSelected = selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                            selectedColor: const Color(0xFFC084FC),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    isStudent ? 'Available Notes' : 'Open Requests',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) => _buildItemCard(item, appState)),

                  const SizedBox(height: 24),
                  
                  const Text('Group Study', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...groups.map((group) => _buildGroupCard(group, appState)),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, AppState appState) {
    return GestureDetector(
      onTap: () => appState.setScreen('chat'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                Text(
                  item['price'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.purple[100],
                  child: Text(
                    (item['author'] as String)[0],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(item['author'], style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                 const Icon(Icons.star, size: 14, color: Colors.amber),
                 Text(' ${item['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (item['tags'] as List<String>).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, AppState appState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
         boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group['title'],
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '${group['members']} members',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => appState.setScreen('chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero, 
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
