import 'package:flutter/material.dart';

// Custom SelectionDetails class to avoid conflict with Flutter's SelectionDetails
class CalendarSelectionDetails {
  final dynamic view;
  final DateTime date;
  final List<dynamic>? appointments;
  final Rect? bounds;
  
  CalendarSelectionDetails(this.view, this.date, {this.appointments, this.bounds});
}