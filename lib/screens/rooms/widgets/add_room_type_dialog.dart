import 'package:flutter/material.dart';
import '../models/room_models.dart';

class AddRoomTypeDialog extends StatefulWidget {
  final Function(RoomType) onRoomTypeAdded;

  const AddRoomTypeDialog({
    super.key,
    required this.onRoomTypeAdded,
  });

  @override
  State<AddRoomTypeDialog> createState() => _AddRoomTypeDialogState();
}

class _AddRoomTypeDialogState extends State<AddRoomTypeDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Room Type', style: TextStyle(fontWeight: FontWeight.bold)),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Room Type Name',
                hintText: 'Enter room type name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amenitiesController,
              decoration: const InputDecoration(
                labelText: 'Amenities (Room only, comma separated)',
                border: OutlineInputBorder()
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addRoomType,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9E8C6D),
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Room Type'),
        ),
      ],
    );
  }

  void _addRoomType() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room type name is required')),
      );
      return;
    }

    final roomType = RoomType(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      amenities: _amenitiesController.text.trim().isEmpty ? null : _amenitiesController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onRoomTypeAdded(roomType);
    Navigator.pop(context);
  }
}
