import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'NoteCreator.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = query.trim();
      });
    });
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp is! Timestamp) return 'Unknown date';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours >= 1) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes >= 1) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }



  void _deleteNote(String docId) {
    FirebaseFirestore.instance.collection('notes').doc(FirebaseAuth.instance.currentUser?.uid).collection("userNotes").doc(docId).delete();
  }

  void _editNote(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteCreationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = MediaQuery.of(context).size.width * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        elevation: 0,
        toolbarHeight: 70,
        title: Text(
          "Notes",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Icon(Icons.push_pin, color: Colors.transparent),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: iconSize),
            onPressed: () {
              showSearchBar(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('userNotes')
              .orderBy('pinned', descending: true)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No notes available',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final allNotes = snapshot.data!.docs;

            final filteredNotes = allNotes.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'].toString().toLowerCase();
              final content = data['content'].toString().toLowerCase();
              return title.contains(searchQuery.toLowerCase()) ||
                  content.contains(searchQuery.toLowerCase());
            }).toList();

            return ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final doc = filteredNotes[index];
                final data = doc.data() as Map<String, dynamic>;

                return GestureDetector(
                  onLongPress: () => _showOptionsDialog(doc),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      color: const Color(0xFF1E1E1E),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['title'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.push_pin,
                                  color: data['isPinned'] == true
                                      ? Colors.grey
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['content'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                data['createdAt'] != null
                                    ? formatTimestamp(data['createdAt'])
                                    : 'Unknown date',
                                style: GoogleFonts.poppins(
                                    color: Colors.white38, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  NoteCreationPage()),
          );
        },
        backgroundColor: const Color(0xFFB9F51B),
        child: const Icon(Icons.add, color: Colors.black, size: 39),
      ),
    );
  }

  void showSearchBar(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(20)),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            filled: true,
            fillColor: const Color(0xFF2C2C2C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _editNote(doc);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title:
              const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _deleteNote(doc.id);

              },
            ),
          ],
        );
      },
    );
  }
}
