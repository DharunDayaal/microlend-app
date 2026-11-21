/// Saving, opening and sharing an export file on this device.
abstract interface class ExportFiles {
  /// Saves [url] as [fileName]; returns the local path. Throws
  /// `ApiException` with code DOWNLOAD_FAILED or DOWNLOAD_EMPTY.
  Future<String> download(
    String url,
    String fileName, {
    void Function(double? progress)? onProgress,
  });

  /// Whether a previously downloaded file is still there.
  bool exists(String path);

  /// Opens the file in another app, or shares it when none can open it.
  Future<void> open(String path);

  Future<void> share(String path);
}
