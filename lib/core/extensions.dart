extension DurationExtension on Duration {
  String toHHMMSS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}h${twoDigits(minutes)}m${twoDigits(seconds)}s';
    } else {
      return '${twoDigits(minutes)}m${twoDigits(seconds)}s';
    }
  }
}
