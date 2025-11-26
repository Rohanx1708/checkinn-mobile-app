class Room {
  final String roomNo;
  final String building;
  final String type;
  String status;
  final int floor;
  DateTime lastCleaned;

  Room({
    required this.roomNo,
    required this.building,
    required this.type,
    required this.status,
    required this.floor,
    required this.lastCleaned,
  });
}

class RoomStatus {
  static const String clean = 'clean';
  static const String dirty = 'dirty';
  static const String inProgress = 'in_progress';
  static const String outOfOrder = 'out_of_order';
  
  static List<String> get all => [clean, dirty, inProgress, outOfOrder];
  
  static String getDisplayLabel(String status) {
    switch (status) {
      case clean:
        return 'Clean';
      case dirty:
        return 'Dirty';
      case inProgress:
        return 'In Progress';
      case outOfOrder:
        return 'Out of Order';
      default:
        return status;
    }
  }
}

class RoomHelper {
  static List<Room> getDefaultRooms() {
    return [
      Room(roomNo: '101', building: 'Building A', type: 'Standard King', status: 'clean', floor: 1, lastCleaned: DateTime.now().subtract(const Duration(days: 1))),
      Room(roomNo: '102', building: 'Building A', type: 'Deluxe Queen', status: 'dirty', floor: 1, lastCleaned: DateTime.now().subtract(const Duration(days: 3))),
      Room(roomNo: '201', building: 'Building B', type: 'Suite', status: 'in_progress', floor: 2, lastCleaned: DateTime.now().subtract(const Duration(days: 2))),
      Room(roomNo: '202', building: 'Building B', type: 'Standard Twin', status: 'clean', floor: 2, lastCleaned: DateTime.now().subtract(const Duration(days: 5))),
      Room(roomNo: '301', building: 'Building C', type: 'Family Room', status: 'out_of_order', floor: 3, lastCleaned: DateTime.now().subtract(const Duration(days: 10))),
      Room(roomNo: '302', building: 'Building C', type: 'Penthouse', status: 'dirty', floor: 3, lastCleaned: DateTime.now().subtract(const Duration(days: 7))),
      Room(roomNo: '401', building: 'Building D', type: 'Standard King', status: 'clean', floor: 4, lastCleaned: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }

  static int countByStatus(List<Room> rooms, String status) {
    return rooms.where((r) => r.status == status).length;
  }

  static List<Room> filterRooms(
    List<Room> rooms,
    String searchQuery,
    String statusFilter,
    String buildingFilter,
    String typeFilter,
  ) {
    final query = searchQuery.trim().toLowerCase();
    String statusValue = statusFilter;

    switch (statusFilter) {
      case 'Clean':
        statusValue = 'clean';
        break;
      case 'Dirty':
        statusValue = 'dirty';
        break;
      case 'In Progress':
        statusValue = 'in_progress';
        break;
      case 'Out of Order':
        statusValue = 'out_of_order';
        break;
    }

    return rooms.where((room) {
      final matchesSearch = query.isEmpty ||
          room.roomNo.toLowerCase().contains(query) ||
          room.building.toLowerCase().contains(query) ||
          room.type.toLowerCase().contains(query);
      final matchesStatus = statusValue == 'All' || room.status == statusValue;
      final matchesBuilding = buildingFilter == 'All' || room.building == buildingFilter;
      final matchesType = typeFilter == 'All' || room.type == typeFilter;
      return matchesSearch && matchesStatus && matchesBuilding && matchesType;
    }).toList();
  }
}
