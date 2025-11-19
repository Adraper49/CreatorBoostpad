package com.knowledgebank.creatorboostpad

import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.lifecycleScope
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import com.knowledgebank.creatorboostpad.zalara.ZalaraClient
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class ZalaraSmokeActivity : ComponentActivity() {

    private var lastUri: Uri? = null
    private lateinit var log: TextView
    private lateinit var playerView: PlayerView
    private var player: ExoPlayer? = null

    private val pickVideo = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        lastUri = uri
        if (uri != null) append("Selected: ${displayName(uri)}")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 32, 32, 32)
        }

        val btnPick = Button(this).apply { text = "Pick short video" }
        val btnRun = Button(this).apply { text = "Send to Zalara (smoke)" }
        log = TextView(this).apply { textSize = 12f }
        playerView = PlayerView(this)

        root.addView(btnPick)
        root.addView(btnRun)
        root.addView(log)
        root.addView(playerView)
        setContentView(root)

        btnPick.setOnClickListener { pickVideo.launch("video/*") }
        btnRun.setOnClickListener { runSmoke() }
    }

    private fun append(msg: String) {
        log.text = (log.text.toString() + "\n" + msg).trim()
    }

    private fun displayName(uri: Uri): String =
        contentResolver.query(uri, null, null, null, null)?.use { c ->
            val idx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (c.moveToFirst() && idx >= 0) c.getString(idx) else uri.lastPathSegment ?: "video.mp4"
        } ?: "video.mp4"

    private fun runSmoke() {
        val uri = lastUri ?: run { append("Pick a video first"); return }
        lifecycleScope.launch {
            try {
                append("Reading file…")
                val bytes = withContext(Dispatchers.IO) {
                    contentResolver.openInputStream(uri)?.use { it.readBytes() } ?: ByteArray(0)
                }
                require(bytes.isNotEmpty()) { "Empty file" }

                val client = ZalaraClient()
                val key = "mobile/boostpad/${System.currentTimeMillis()}_${displayName(uri)}"

                append("Presigning…")
                append("BASE = " + BuildConfig.ZALARA_BASE_URL)
                append("HITTING = ${BuildConfig.ZALARA_BASE_URL}/presign")

                val p = client.presignInbox(key)

                append("Uploading…")
                client.uploadToPresigned(p.url, bytes)

                append("Creating job…")
                val jobId = client.createVideoPack(srcUrl = p.url)

                append("Polling…")
                val status = client.pollUntilDone(jobId)
                append("Status: ${status.status}  ${status.error ?: ""}")

                val hls = (status.outputs?.get("hls") as? Map<*, *>)?.get("m3u8") as? String
                if (hls != null) {
                    playHls(hls)
                } else {
                    append("No m3u8 in outputs")
                }
            } catch (e: Exception) {
                append("ERROR: ${e.message}")
            }
        }
    }

    private fun playHls(url: String) {
        player?.release()
        player = ExoPlayer.Builder(this).build().also { p ->
            playerView.player = p
            p.setMediaItem(MediaItem.fromUri(url))
            p.prepare()
            p.play()
        }
    }

    override fun onStop() {
        super.onStop()
        player?.pause()
    }

    override fun onDestroy() {
        super.onDestroy()
        player?.release()
        player = null
    }
}

