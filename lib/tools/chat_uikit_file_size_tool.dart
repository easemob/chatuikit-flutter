class ChatUIKitFileSizeTool {
  static String fileSize(int fileSize) {
    if (fileSize < 1024) {
      return "${fileSize}B";
    } else if (fileSize < 1024 * 1024) {
      return "${(fileSize / 1024).toStringAsFixed(2)}kb";
    } else if (fileSize < 1024 * 1024 * 1024) {
      return "${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB";
    } else {
      return "${(fileSize / 1024 / 1024 / 1024).toStringAsFixed(2)}GB";
    }
  }
}
