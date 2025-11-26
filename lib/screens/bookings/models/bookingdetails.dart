class Booking {
  final String id;
  final String title;
  final String companyName;
  final String imageUrl;
  final DateTime date;
  final String status;
  final double amountSpend;
  final double balanceDue;
  final String address;
  final String? notes;

  // New fields
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String roomDetails;
  final double bookingFee;

  // Customer information
  final Customer customer;
  final int totalGuests;
  final String? remarks;
  
  // Room information
  final String roomType;
  final String selectedRoom;
  final String? roomRemarks;
  final int? roomTypeId;
  final int? roomId;
  
  // Property information
  final String? propertyName;
  final String? propertyAddress;
  final String? propertyId;
  
  // Additional booking information
  final String? paymentStatus;
  final String? source;
  
  // Billing information
  final double subtotal;
  final double gst;
  final double totalCost;
  final double? discount;
  final double finalAmount;
  
  // Additional information
  final List<Guest> guests;
  final Guide? guide;
  final List<Extra> extras;
  final List<AddOn> addOns;

  Booking({
    required this.id,
    required this.title,
    required this.companyName,
    required this.imageUrl,
    required this.date,
    required this.status,
    required this.amountSpend,
    required this.balanceDue,
    required this.address,
    this.notes,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomDetails,
    required this.bookingFee,
    required this.customer,
    required this.totalGuests,
    this.remarks,
    required this.roomType,
    required this.selectedRoom,
    this.roomRemarks,
    this.roomTypeId,
    this.roomId,
    this.propertyName,
    this.propertyAddress,
    this.propertyId,
    this.paymentStatus,
    this.source,
    required this.subtotal,
    required this.gst,
    required this.totalCost,
    this.discount,
    required this.finalAmount,
    this.guests = const [],
    this.guide,
    this.extras = const [],
    this.addOns = const [],
  });

  // ✅ Factory constructor to create from API map
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map["id"]?.toString() ?? "",
      title: map["property"]?["name"]?.toString() ?? map["title"]?.toString() ?? "",
      companyName: map["source"]?.toString() ?? "",
      imageUrl: map["imageUrl"]?.toString() ?? "",
      date: _parseDate(map["created_at"]),
      status: map["booking_status"]?.toString() ?? map["status"]?.toString() ?? "",
      amountSpend: _toDouble(map["total_amount"]),
      balanceDue: _toDouble(map["balance_due"]),
      address: map["property"]?["address"]?.toString() ?? map["address"]?.toString() ?? "",
      notes: map["special_requests"]?.toString() ?? map["notes"]?.toString(),
      checkInDate: _parseDate(map["check_in_date"]),
      checkOutDate: _parseDate(map["check_out_date"]),
      roomDetails: map["room_type"]?["name"]?.toString() ?? map["roomDetails"]?.toString() ?? "",
      bookingFee: _toDouble(map["booking_fee"]),
      customer: Customer(
        name: map["guest_name"]?.toString() ?? map["customer"]?["name"]?.toString() ?? "",
        phone: map["guest_phone"]?.toString() ?? map["customer"]?["phone"]?.toString() ?? "",
        email: map["guest_email"]?.toString() ?? map["customer"]?["email"]?.toString() ?? "",
        address: map["guest_address"]?.toString() ?? map["customer"]?["address"]?.toString() ?? "",
        idProof: map["id_proof"]?.toString() ?? map["customer"]?["idProof"]?.toString() ?? "",
        idProofNumber: map["id_proof_number"]?.toString() ?? map["customer"]?["idProofNumber"]?.toString() ?? "",
      ),
      totalGuests: map["guest_count"] is int ? map["guest_count"] : int.tryParse(map["guest_count"]?.toString() ?? "0") ?? 0,
      remarks: map["special_requests"]?.toString() ?? map["remarks"]?.toString(),
      roomType: (() {
        // 1) Explicit array of room_types
        final rtList = map["room_types"];
        if (rtList is List && rtList.isNotEmpty) {
          final names = rtList
              .map((e) {
                if (e is Map) return e["name"]?.toString();
                return e?.toString();
              })
              .where((e) => e != null && e!.isNotEmpty)
              .cast<String>()
              .toList();
          if (names.isNotEmpty) return names.join(', ');
        }
        // 2) booking_rooms -> room.room_type.name or room_type_name
        final br = map["booking_rooms"];
        if (br is List && br.isNotEmpty) {
          final names = br.map((e) {
            if (e is Map) {
              final room = e["room"];
              if (room is Map) {
                final rt = room["room_type"];
                if (rt is Map && rt["name"] != null) return rt["name"].toString();
              }
              if (e["room_type_name"] != null) return e["room_type_name"].toString();
            }
            return null;
          }).where((e) => e != null && e!.isNotEmpty).cast<String>().toList();
          if (names.isNotEmpty) return names.join(', ');
        }
        // 3) rooms[] -> room_type.name
        final rooms = map["rooms"];
        if (rooms is List && rooms.isNotEmpty) {
          final names = rooms.map((r) {
            if (r is Map) {
              final rt = r["room_type"];
              if (rt is Map && rt["name"] != null) return rt["name"].toString();
            }
            return null;
          }).where((e) => e != null && e!.isNotEmpty).cast<String>().toList();
          if (names.isNotEmpty) return names.join(', ');
        }
        // 4) single room_type
        if (map["room_type"] is Map && (map["room_type"]["name"] != null)) {
          return map["room_type"]["name"].toString();
        }
        // 5) fallbacks
        return map["room_type_name"]?.toString()
            ?? map["room_type"]?.toString()
            ?? map["roomType"]?.toString()
            ?? "";
      })(),
      selectedRoom: map["selected_room"]?.toString()
          ?? map["room_number"]?.toString()
          ?? (map["room"] is Map && (map["room"]["room_number"] != null)
              ? map["room"]["room_number"].toString()
              : null)
          ?? (() {
                // rooms array case
                final rooms = map["rooms"];
                if (rooms is List && rooms.isNotEmpty && rooms.first is Map) {
                  try {
                    // join all available room_numbers
                    final labels = rooms
                        .map((e) => (e as Map)["room_number"]?.toString())
                        .where((e) => e != null && e!.isNotEmpty)
                        .cast<String>()
                        .toList();
                    if (labels.isNotEmpty) return labels.join(', ');
                  } catch (_) {}
                  return (rooms.first as Map)["room_number"]?.toString();
                }
                // booking_rooms nested
                final br = map["booking_rooms"];
                if (br is List && br.isNotEmpty && br.first is Map) {
                  try {
                    final labels = br.map((e) {
                      final row = e as Map;
                      if (row["room"] is Map && row["room"]["room_number"] != null) {
                        return row["room"]["room_number"].toString();
                      }
                      if (row["room_number"] != null) return row["room_number"].toString();
                      return null;
                    }).where((e) => e != null).cast<String>().toList();
                    if (labels.isNotEmpty) return labels.join(', ');
                  } catch (_) {}
                  final first = br.first as Map;
                  if (first["room"] is Map && (first["room"]["room_number"] != null)) {
                    return first["room"]["room_number"].toString();
                  }
                  if (first["room_number"] != null) return first["room_number"].toString();
                }
                final allocated = map["allocated_room"];
                if (allocated is Map && allocated["room_number"] != null) {
                  return allocated["room_number"].toString();
                }
                return null;
              }())
          ?? map["selectedRoom"]?.toString()
          ?? "",
      roomRemarks: map["room_remarks"]?.toString() ?? map["roomRemarks"]?.toString(),
      roomTypeId: map["room_type_id"] is int ? map["room_type_id"] : int.tryParse(map["room_type_id"]?.toString() ?? ""),
      roomId: (map["room_id"] is int ? map["room_id"] : int.tryParse(map["room_id"]?.toString() ?? ""))
          ?? (() {
                // room.id
                final r = map["room"];
                if (r is Map && r["id"] != null) {
                  final v = r["id"].toString();
                  return int.tryParse(v);
                }
                // booking_rooms[0].room_id
                final br = map["booking_rooms"];
                if (br is List && br.isNotEmpty && br.first is Map) {
                  final v = (br.first as Map)["room_id"]?.toString();
                  return v != null ? int.tryParse(v) : null;
                }
                // rooms[0].id
                final rooms = map["rooms"];
                if (rooms is List && rooms.isNotEmpty && rooms.first is Map) {
                  final v = (rooms.first as Map)["id"]?.toString();
                  return v != null ? int.tryParse(v) : null;
                }
                return null;
              }()),
      propertyName: map["property"]?["name"]?.toString() ?? map["property_name"]?.toString(),
      propertyAddress: map["property"]?["address"]?.toString() ?? map["property_address"]?.toString(),
      propertyId: map["property_id"]?.toString(),
      paymentStatus: map["payment_status"]?.toString(),
      source: map["source"]?.toString(),
      subtotal: _toDouble(map["subtotal"]),
      gst: _toDouble(map["gst"]),
      totalCost: _toDouble(map["total_amount"]),
      discount: map["discount"] != null ? _toDouble(map["discount"]) : null,
      finalAmount: _toDouble(map["total_amount"]),
      guests: (map["guests"] as List? ?? [])
          .map((g) => Guest.fromMap(g as Map<String, dynamic>))
          .toList(),
      guide: map["guide"] != null
          ? Guide.fromMap(map["guide"] as Map<String, dynamic>)
          : null,
      extras: (map["extras"] as List? ?? [])
          .map((e) => Extra.fromMap(e as Map<String, dynamic>))
          .toList(),
      addOns: (map["addOns"] as List? ?? [])
          .map((a) => AddOn.fromMap(a as Map<String, dynamic>))
          .toList(),
    );
  }

  // ✅ Factory constructor to create from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking.fromMap(json);
  }

  // ✅ Convert to Map (for sending to API)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "companyName": companyName,
      "imageUrl": imageUrl,
      "date": date.toIso8601String(),
      "status": status,
      "amountSpend": amountSpend,
      "balanceDue": balanceDue,
      "address": address,
      "notes": notes,
      "checkInDate": checkInDate.toIso8601String(),
      "checkOutDate": checkOutDate.toIso8601String(),
      "roomDetails": roomDetails,
      "bookingFee": bookingFee,
      "customer": customer.toMap(),
      "totalGuests": totalGuests,
      "remarks": remarks,
      "roomType": roomType,
      "selectedRoom": selectedRoom,
      "roomRemarks": roomRemarks,
      "subtotal": subtotal,
      "gst": gst,
      "totalCost": totalCost,
      "discount": discount,
      "finalAmount": finalAmount,
      "guests": guests.map((g) => g.toMap()).toList(),
      "guide": guide?.toMap(),
      "extras": extras.map((e) => e.toMap()).toList(),
      "addOns": addOns.map((a) => a.toMap()).toList(),
    };
  }

  // ✅ Helper for safe parsing
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // ✅ CopyWith method for immutability
  Booking copyWith({
    String? id,
    String? title,
    String? companyName,
    String? imageUrl,
    DateTime? date,
    String? status,
    double? amountSpend,
    double? balanceDue,
    String? address,
    String? notes,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? roomDetails,
    double? bookingFee,
    Customer? customer,
    int? totalGuests,
    String? remarks,
    String? roomType,
    String? selectedRoom,
    String? roomRemarks,
    double? subtotal,
    double? gst,
    double? totalCost,
    double? discount,
    double? finalAmount,
    List<Guest>? guests,
    Guide? guide,
    List<Extra>? extras,
    List<AddOn>? addOns,
  }) {
    return Booking(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      status: status ?? this.status,
      amountSpend: amountSpend ?? this.amountSpend,
      balanceDue: balanceDue ?? this.balanceDue,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      roomDetails: roomDetails ?? this.roomDetails,
      bookingFee: bookingFee ?? this.bookingFee,
      customer: customer ?? this.customer,
      totalGuests: totalGuests ?? this.totalGuests,
      remarks: remarks ?? this.remarks,
      roomType: roomType ?? this.roomType,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      roomRemarks: roomRemarks ?? this.roomRemarks,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      totalCost: totalCost ?? this.totalCost,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      guests: guests ?? this.guests,
      guide: guide ?? this.guide,
      extras: extras ?? this.extras,
      addOns: addOns ?? this.addOns,
    );
  }
}

// ====================== Guest Model ======================
class Guest {
  final String name;
  final String email;
  final String phone;

  Guest({required this.name, required this.email, required this.phone});

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      name: map["name"]?.toString() ?? "",
      email: map["email"]?.toString() ?? "",
      phone: map["phone"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
    };
  }
}

// ====================== Guide Model ======================
class Guide {
  final String name;
  final String phone;

  Guide({required this.name, required this.phone});

  factory Guide.fromMap(Map<String, dynamic> map) {
    return Guide(
      name: map["name"]?.toString() ?? "",
      phone: map["phone"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
    };
  }
}

// ====================== Extra Model ======================
class Extra {
  final String name;
  final int quantity;
  final double price;

  Extra({required this.name, required this.quantity, required this.price});

  factory Extra.fromMap(Map<String, dynamic> map) {
    return Extra(
      name: map["name"]?.toString() ?? "",
      quantity: (map["quantity"] is int)
          ? map["quantity"]
          : int.tryParse(map["quantity"]?.toString() ?? "0") ?? 0,
      price: Booking._toDouble(map["price"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }
}

// ====================== AddOn Model ======================
class AddOn {
  final String name;
  final double price;

  AddOn({required this.name, required this.price});

  factory AddOn.fromMap(Map<String, dynamic> map) {
    return AddOn(
      name: map["name"]?.toString() ?? "",
      price: Booking._toDouble(map["price"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "price": price,
    };
  }
}

// ====================== Customer Model ======================
class Customer {
  final String name;
  final String phone;
  final String? email;
  final String address;
  final String idProof;
  final String idProofNumber;

  Customer({
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    required this.idProof,
    required this.idProofNumber,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map["name"]?.toString() ?? "",
      phone: map["phone"]?.toString() ?? "",
      email: map["email"]?.toString(),
      address: map["address"]?.toString() ?? "",
      idProof: map["idProof"]?.toString() ?? "",
      idProofNumber: map["idProofNumber"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "email": email,
      "address": address,
      "idProof": idProof,
      "idProofNumber": idProofNumber,
    };
  }
}
