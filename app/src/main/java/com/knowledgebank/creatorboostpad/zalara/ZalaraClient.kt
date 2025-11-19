package com.knowledgebank.creatorboostpad.zalara

import com.knowledgebank.creatorboostpad.BuildConfig
import com.squareup.moshi.Json
import com.squareup.moshi.Moshi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import retrofit2.HttpException
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path
import java.util.concurrent.TimeUnit

data class PresignReq(val kind: String, val key: String)
data class PresignResp(
    val mode: String?,
    val url: String,
    val token: String?,
    val bucket: String?,
    val key: String?
)
data class CreateJobResp(val ok: Boolean, val jobId: String?)
data class JobStatus(
    val id: String,
    val status: String,
    @Json(name = "outputs_json") val outputs: Map<String, Any>?,
    val error: String?
)
data class JobPayload(
    val type: String,
    val priority: String = "normal",
    val inputs: Map<String, Any>,
    val profile: String = "social_1080x1920@30",
    val webhook: String? = null
)

interface ZalaraApi {
    // primary: /functions/v1/presign
    @POST("presign")
    suspend fun presign(@Body body: PresignReq): PresignResp

    // fallback: /functions/v1/zalara-presign
    @POST("zalara-presign")
    suspend fun presignAlt(@Body body: PresignReq): PresignResp

    @POST("jobs")
    suspend fun createJob(@Body body: JobPayload): CreateJobResp

    @GET("jobs/{id}")
    suspend fun getJob(@Path("id") id: String): JobStatus
}

class ZalaraClient(
    private val baseUrl: String = BuildConfig.ZALARA_BASE_URL,
    private val jwtProvider: () -> String = { BuildConfig.SUPABASE_ANON_JWT }
) {
    // make sure we always have a trailing slash
    private val base = if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/"

    private val moshi = Moshi.Builder().build()

    private val ok = OkHttpClient.Builder()
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .callTimeout(120, TimeUnit.SECONDS)
        .addInterceptor { chain ->
            val token = jwtProvider()
            val req = chain.request().newBuilder()
                .addHeader("Authorization", "Bearer $token")
                .addHeader("apikey", token)   // Supabase style
                .build()
            chain.proceed(req)
        }
        .build()

    private val api: ZalaraApi = Retrofit.Builder()
        .baseUrl(base)
        .client(ok)
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .build()
        .create(ZalaraApi::class.java)

    // what the Activity calls
    suspend fun presignInbox(key: String): PresignResp {
        val body = PresignReq(kind = "inbox", key = key)
        return try {
            api.presign(body)
        } catch (e: HttpException) {
            if (e.code() == 404) {
                api.presignAlt(body)
            } else {
                throw e
            }
        }
    }

    suspend fun uploadToPresigned(
        url: String,
        bytes: ByteArray,
        contentType: String = "video/mp4"
    ) {
        withContext(Dispatchers.IO) {
            val body = bytes.toRequestBody(contentType.toMediaType())
            ok.newCall(Request.Builder().url(url).put(body).build()).execute().use { resp ->
                if (!resp.isSuccessful) error("Upload failed: ${resp.code}")
            }
        }
    }

    suspend fun createVideoPack(srcUrl: String, profile: String = "social_1080x1920@30"): String {
        val inputs = mapOf("clips" to listOf(mapOf("src" to srcUrl, "start" to 0.0)))
        val payload = JobPayload(type = "video_pack", inputs = inputs, profile = profile)
        val r = api.createJob(payload)
        require(r.ok && r.jobId != null) { "Job creation failed" }
        return r.jobId!!
    }

    suspend fun pollUntilDone(jobId: String, maxMs: Long = 120_000, stepMs: Long = 2_000): JobStatus {
        val t0 = System.currentTimeMillis()
        while (true) {
            val s = api.getJob(jobId)
            if (s.status in listOf("done", "failed", "dead")) return s
            if (System.currentTimeMillis() - t0 > maxMs) error("Timeout waiting on job")
            delay(stepMs)
        }
    }
}


