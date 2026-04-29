import 'package:flutter/material.dart';
import 'package:glowstar/model/interest_tag.dart';

/// Interest Selection Screen for GlowStar
/// 
/// Allows users to select their interests for better matching
class InterestSelectionScreen extends StatefulWidget {
  @override
  _InterestSelectionScreenState createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  List<InterestTag> _selectedTags = [];
  String _selectedCategory = 'all';

  List<InterestTag> get _allTags => InterestCategories.getAllTags();

  List<InterestTag> get _filteredTags {
    if (_selectedCategory == 'all') return _allTags;
    return _allTags.where((tag) => tag.category.toLowerCase() == _selectedCategory).toList();
  }

  void _toggleTag(InterestTag tag) {
    setState(() {
      if (_selectedTags.any((t) => t.id == tag.id)) {
        _selectedTags.removeWhere((t) => t.id == tag.id);
      } else {
        if (_selectedTags.length < 10) {
          _selectedTags.add(tag.copyWith(isSelected: true));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Interests'),
        actions: [
          TextButton(
            onPressed: _selectedTags.length >= 3 ? () {
              Navigator.of(context).pop(_selectedTags);
            } : null,
            child: Text(
              'Done (${_selectedTags.length}/10)',
              style: TextStyle(
                color: _selectedTags.length >= 3 ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select at least 3 interests (max 10)',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          _buildCategoryFilter(),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredTags.length,
              itemBuilder: (context, index) {
                return _buildTagCard(_filteredTags[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip('All', 'all'),
          ...InterestCategories.categories.map((cat) => 
            _buildCategoryChip(cat['icon'], cat['id'])
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String categoryId) {
    bool isSelected = _selectedCategory == categoryId;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 16)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = categoryId;
          });
        },
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTagCard(InterestTag tag) {
    bool isSelected = _selectedTags.any((t) => t.id == tag.id);
    return GestureDetector(
      onTap: () => _toggleTag(tag),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tag.icon, style: TextStyle(fontSize: 28)),
            SizedBox(height: 4),
            Text(
              tag.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
