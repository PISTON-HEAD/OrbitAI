import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NoteCreationPage extends StatefulWidget {
  @override
  _NoteCreationPageState createState() => _NoteCreationPageState();
}

class _NoteCreationPageState extends State<NoteCreationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _tags = [];
  bool _isPinned = false;
  bool _isLocked = false;
  bool _showPreview = false;
  List<PlatformFile> _attachments = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_saveDraftLocally);
    _contentController.addListener(_saveDraftLocally);
    _loadDraft();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveDraftLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = jsonEncode({
      'title': _titleController.text,
      'content': _contentController.text,
      'tags': _tags,
      'isPinned': _isPinned,
      'isLocked': _isLocked,
    });
    await prefs.setString('draft_note', draft);
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString('draft_note');
    if (draftStr != null) {
      final draft = jsonDecode(draftStr);
      _titleController.text = draft['title'] ?? '';
      _contentController.text = draft['content'] ?? '';
      _tags.addAll(List<String>.from(draft['tags'] ?? []));
      _isPinned = draft['isPinned'] ?? false;
      _isLocked = draft['isLocked'] ?? false;
    }
  }

  Future<void> _clearLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_note');
  }

  Future<void> _saveNoteToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    final timestamp = Timestamp.now();
    final noteId = '${user.uid}_${timestamp.seconds}';

    try {
      await FirebaseFirestore.instance.collection('notes').doc(user.uid).collection("userNotes").doc(timestamp.seconds.toString()).set({
        'userId': user.uid,
        'title': title,
        'content': content,
        'tags': _tags,
        'locked': _isLocked,
        'attachments': _attachments.map((file) => file.name).toList(),
        'pinned': _isPinned,
        'createdAt': timestamp,
        'updatedAt': timestamp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $error')),
      );
    } finally {
      await _clearLocalDraft();
    }
  }

  Future<bool> _onWillPop() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty || content.isNotEmpty) {
      // Background save without blocking UI
      Future.microtask(() => _saveNoteToFirestore());
    }

    return true; // allow back navigation immediately
  }

  void _pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        setState(() => _attachments.addAll(result.files));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick files.')),
      );
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
        if (tag == 'Lock') _isLocked = false;
      } else {
        _tags.add(tag);
        if (tag == 'Lock') _isLocked = true;
      }
    });
  }

  Widget _buildTagSelector() {
    final List<String> tagOptions = ['Work', 'Idea', 'Personal', 'Urgent', 'To-Do', 'Lock'];
    return Wrap(
      spacing: 8,
      children: tagOptions.map((tag) {
        final isSelected = _tags.contains(tag);
        return ChoiceChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (_) => _toggleTag(tag),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('New Note'),
          actions: [
            IconButton(
              icon: Icon(Icons.push_pin, color: _isPinned ? Colors.yellow : Colors.white),
              onPressed: () => setState(() => _isPinned = !_isPinned),
            ),
            IconButton(
              icon: _isSaving
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Icon(Icons.save),
              onPressed: _isSaving
                  ? null
                  : () async {
                setState(() => _isSaving = true);
                await _saveNoteToFirestore();
                setState(() => _isSaving = false);
                Navigator.pop(context); // Go back to the previous screen
              },

            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleController,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                        SizedBox(height: 8),
                        _showPreview
                            ? Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MarkdownBody(
                            data: _contentController.text,
                            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(p: TextStyle(color: Colors.white)),
                          ),
                        )
                            : TextField(
                          controller: _contentController,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Write your note here...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Tags:', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 8),
                        _buildTagSelector(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickAttachments,
                            icon: Icon(Icons.attach_file),
                            label: Text('Add Files'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _showPreview = !_showPreview),
                            icon: Icon(Icons.visibility),
                            label: Text(_showPreview ? 'Edit' : 'Preview'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
