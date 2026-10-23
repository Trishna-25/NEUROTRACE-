import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Each user's data lives under users/{uid}/...
DocumentReference get _userDoc => FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid);

Future<void> saveReading(List<double> f, String type, double conf, double risk) {
  return _userDoc.collection('readings').add({
    'time': FieldValue.serverTimestamp(),
    'hr': f[0],
    'spo2': f[1],
    'rmssd': f[2],
    'skin_temp': f[3],
    'amb_temp': f[4],
    'humidity': f[5],
    'pressure': f[6],
    'activity': f[7],
    'predicted_type': type,
    'confidence': conf,
    'risk': risk,
  });
}

Future<void> saveHeadacheLog(
  int intensity,
  double sleepHours,
  int water,
  int stress, {
  String? type,
  String? notes,
}) {
  return _userDoc.collection('headache_logs').add({
    'time': FieldValue.serverTimestamp(),
    'intensity': intensity,
    'sleep_hours': sleepHours,
    'water_glasses': water,
    'stress': stress,
    if (type != null) 'type': type,
    if (notes != null && notes.isNotEmpty) 'notes': notes,
  });
}