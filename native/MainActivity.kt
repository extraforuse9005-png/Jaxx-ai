package __PACKAGE__

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "jaxx/native")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "listApps" -> result.success(listLaunchableApps())
                    "launchApp" -> result.success(launchApp(call.argument<String>("package")))
                    "openUrl" -> result.success(openUrl(call.argument<String>("url")))
                    else -> result.notImplemented()
                }
            }
    }

    private fun listLaunchableApps(): List<Map<String, String>> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val infos = packageManager.queryIntentActivities(intent, 0)
        return infos
            .map {
                mapOf(
                    "name" to it.loadLabel(packageManager).toString(),
                    "package" to it.activityInfo.packageName
                )
            }
            .distinctBy { it["package"] }
            .sortedBy { it["name"]?.lowercase() }
    }

    private fun launchApp(pkg: String?): Boolean {
        if (pkg.isNullOrEmpty()) return false
        val launch = packageManager.getLaunchIntentForPackage(pkg) ?: return false
        launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(launch)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun openUrl(url: String?): Boolean {
        if (url.isNullOrEmpty()) return false
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }
}
