package com.example.micro_lending_app

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Streams the phone's network to Dart ("thavanai/network"): connected or not,
 * whether Android has checked that the internet really works (VALIDATED),
 * Wi-Fi or mobile, and Android's own bandwidth estimate. Nothing is
 * downloaded to find these out.
 */
class NetworkStreamHandler(context: Context) : EventChannel.StreamHandler {
    private val connectivity =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var callback: ConnectivityManager.NetworkCallback? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
        // the current network first (no callback fires when there is none)
        send(connectivity.activeNetwork?.let { connectivity.getNetworkCapabilities(it) })

        val cb = object : ConnectivityManager.NetworkCallback() {
            override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) =
                send(caps)

            override fun onLost(network: Network) = send(null)
        }
        callback = cb
        connectivity.registerDefaultNetworkCallback(cb)
    }

    override fun onCancel(arguments: Any?) {
        callback?.let {
            try {
                connectivity.unregisterNetworkCallback(it)
            } catch (_: IllegalArgumentException) {
                // already unregistered
            }
        }
        callback = null
        sink = null
    }

    /** [caps] null means no network at all. */
    private fun send(caps: NetworkCapabilities?) {
        val event: Map<String, Any?> = if (caps == null) {
            mapOf("connected" to false)
        } else {
            mapOf(
                "connected" to caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET),
                "validated" to caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED),
                "transport" to when {
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
                    caps.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
                    else -> "other"
                },
                // Android's estimate from the network type and signal, in kbps
                "downKbps" to caps.linkDownstreamBandwidthKbps,
            )
        }
        // callbacks arrive on a background thread; Flutter needs the main one
        main.post { sink?.success(event) }
    }

    companion object {
        const val CHANNEL = "thavanai/network"
    }
}
