import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      default: return android;
    }
  }
  static const FirebaseOptions web = FirebaseOptions(apiKey: 'AIzaSyAJR1-V0x-JdrMHwJIxYosHYvi77nFNn7c', appId: '1:697104593083:web:63429fbfd94837f483b99e', messagingSenderId: '697104593083', projectId: 'forceapp-2573e', authDomain: 'forceapp-2573e.firebaseapp.com', storageBucket: 'forceapp-2573e.firebasestorage.app');
  static const FirebaseOptions android = FirebaseOptions(apiKey: 'AIzaSyB26Oclj50Oy4spVQfHcbzAk16Bjri25Hc', appId: '1:697104593083:android:dd64312e6ba30f3583b99e', messagingSenderId: '697104593083', projectId: 'forceapp-2573e', storageBucket: 'forceapp-2573e.firebasestorage.app');
}
