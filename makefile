apk:
	fvm flutter clean && rm -f pubspec.lock
	fvm flutter pub get
	fvm dart pub run build_runner build
	fvm flutter build apk --release