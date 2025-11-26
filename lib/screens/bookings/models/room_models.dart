class RoomInfo {
  final String number;
  final int capacity;
  final double price;
  final int floor;

  const RoomInfo({
    required this.number,
    required this.capacity,
    required this.price,
    required this.floor,
  });

  factory RoomInfo.fromMap(Map<String, dynamic> map) {
    return RoomInfo(
      number: map['number'] as String,
      capacity: map['capacity'] as int,
      price: (map['price'] as num).toDouble(),
      floor: map['floor'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'number': number,
        'capacity': capacity,
        'price': price,
        'floor': floor,
      };
}


