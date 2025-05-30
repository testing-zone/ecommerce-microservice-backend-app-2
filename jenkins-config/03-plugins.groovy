#!groovy
import jenkins.model.*
import hudson.PluginManager
import hudson.PluginWrapper

def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()

// List of essential plugins
def plugins = [
    "git",
    "workflow-aggregator", 
    "pipeline-stage-view",
    "docker-workflow",
    "junit",
    "maven-plugin",
    "build-timeout",
    "timestamper"
]

// Install plugins
def installed = false
plugins.each { pluginName ->
    if (!pm.getPlugin(pluginName)) {
        println "Installing plugin: ${pluginName}"
        def plugin = uc.getPlugin(pluginName)
        if (plugin) {
            plugin.deploy(true)
            installed = true
        }
    } else {
        println "Plugin already installed: ${pluginName}"
    }
}

if (installed) {
    println "✅ Plugins installed successfully!"
    println "🔄 Jenkins will restart to activate plugins..."
    instance.safeRestart()
} else {
    println "✅ All required plugins are already installed!"
} 