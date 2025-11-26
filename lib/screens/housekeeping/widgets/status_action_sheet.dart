import 'package:flutter/material.dart';
import '../models/room_model.dart';

class StatusActionSheet extends StatelessWidget {
  final Room room;
  final Function(Room, String) onStatusUpdate;

  const StatusActionSheet({
    super.key,
    required this.room,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Mark as Clean'),
            onTap: () => onStatusUpdate(room, 'clean'),
          ),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Mark as Dirty'),
            onTap: () => onStatusUpdate(room, 'dirty'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.orange),
            title: const Text('Mark as In Progress'),
            onTap: () => onStatusUpdate(room, 'in_progress'),
          ),
          ListTile(
            leading: const Icon(Icons.bed, color: Colors.blue),
            title: const Text('Mark as Out of Order'),
            onTap: () => onStatusUpdate(room, 'out_of_order'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
