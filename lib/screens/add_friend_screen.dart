import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;


  // Przykładowe dane
  List<Map<String, String>> requests = [
    {'nickname': 'john_doe', 'avatar': ''},
    {'nickname': 'jane_smith', 'avatar': ''},
  ];
  List<Map<String, String>> searchResults = [
    {'nickname': 'new_user', 'avatar': ''},
    {'nickname': 'another_user', 'avatar': ''},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Add friend',
          style: TextStyle(color: AppColors.textLight),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pasek wyszukiwania
            // Zamiast samego TextField:
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 400, // np. 320px, możesz dostosować
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(color: AppColors.textDim),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textDim),
                    filled: true,
                    fillColor: _isSearchFocused
                        ? AppColors.cardBackground.withOpacity(0.5)
                        : AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32), // bardziej zaokrąglone
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: obsługa wyszukiwania
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Requests
            if (requests.isNotEmpty) ...[
              Row(
                children: const [
                  Text(
                    'Requests',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...requests.map(
                (user) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.textDim,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.cardBackground,
                      ),
                    ),
                    title: Text(
                      user['nickname'] ?? '',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                      child: const Text(
                        'New friend request!',
                        style: TextStyle(
                          color: AppColors.peaceful,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textDim,
                          ),
                          onPressed: () {
                            // TODO: odrzuć request
                          },
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppColors.textDim.withOpacity(0.4),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: AppColors.peaceful,
                          ),
                          onPressed: () {
                            // TODO: zaakceptuj request
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Divider(
              color: AppColors.textDim.withOpacity(0.2),
              thickness: 1,
              height: 10,
            ),
            const SizedBox(height: 16),
            // Add new friend
            Row(
              children: const [
                Text(
                  'Add new friend',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: searchResults
                    .map(
                      (user) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.textDim,
                            child: const Icon(
                              Icons.person,
                              color: AppColors.cardBackground,
                            ),
                          ),
                          title: Text(
                            user['nickname'] ?? '',
                            style: const TextStyle(color: AppColors.textLight),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.peaceful,
                            ),
                            onPressed: () {
                              // TODO: wyślij request
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
