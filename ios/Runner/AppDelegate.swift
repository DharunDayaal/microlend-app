import Flutter
import Network
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Kept here so it lives as long as the app.
  private let network = NetworkStreamHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ThavanaiNetwork") {
      FlutterEventChannel(name: NetworkStreamHandler.channel, binaryMessenger: registrar.messenger())
        .setStreamHandler(network)
    }
  }
}

/// Streams the phone's network to Dart ("thavanai/network"): connected or
/// not, and Wi-Fi or mobile. iOS gives no speed estimate and no "internet
/// really works" check, so Dart confirms with /health when it comes back.
final class NetworkStreamHandler: NSObject, FlutterStreamHandler {
  static let channel = "thavanai/network"
  private var monitor: NWPathMonitor?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
      let transport: String
      if path.usesInterfaceType(.wifi) {
        transport = "wifi"
      } else if path.usesInterfaceType(.cellular) {
        transport = "cellular"
      } else if path.usesInterfaceType(.wiredEthernet) {
        transport = "ethernet"
      } else {
        transport = "other"
      }
      let event: [String: Any] = [
        "connected": path.status == .satisfied,
        "transport": transport,
      ]
      // Flutter channels must be used on the main thread
      DispatchQueue.main.async { events(event) }
    }
    monitor.start(queue: DispatchQueue(label: "thavanai.network"))
    self.monitor = monitor
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    monitor?.cancel()
    monitor = nil
    return nil
  }
}
