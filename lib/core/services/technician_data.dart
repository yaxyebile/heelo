import 'package:flutter/material.dart';

// ─── Simple in-memory store (replace with Supabase later) ─────────────────────
class TechnicianData {
  static final List<Map<String, dynamic>> technicians = [];
  static final Map<String, Map<String, double>> pricing = {
    'Korontada':             {'Sare': 50, 'Dhex Dhexaad': 30, 'Hoose': 15},
    'Qaboojiyaha (AC)':      {'Sare': 60, 'Dhex Dhexaad': 35, 'Hoose': 20},
    'Qasaaladaha':           {'Sare': 40, 'Dhex Dhexaad': 25, 'Hoose': 12},
    'Tuubooyinka (Plumbing)':{'Sare': 45, 'Dhex Dhexaad': 28, 'Hoose': 14},
    'Xirfadaha kale':        {'Sare': 35, 'Dhex Dhexaad': 22, 'Hoose': 10},
  };
  static final List<Map<String, dynamic>> bookings = [];
}
