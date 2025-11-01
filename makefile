clean:
	fvm flutter clean && rm -f pubspec.lock

setup:
	fvm flutter pub get
	fvm dart pub run build_runner build

docker-apk:
	docker build --platform linux/amd64 -t app-builder .
	docker create --name tmp-container app-builder
	docker cp tmp-container:/app/build/app/outputs/flutter-apk/app-release.apk ./app-unsigned.apk
	docker rm tmp-container