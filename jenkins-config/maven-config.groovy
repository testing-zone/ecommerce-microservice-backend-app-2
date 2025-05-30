#!groovy
import jenkins.model.*
import hudson.tasks.Maven
import hudson.tools.*

def instance = Jenkins.getInstance()

// Configure Maven
def mavenDesc = instance.getDescriptor(Maven.class)
def mavenInstallations = [
  new Maven.MavenInstallation("Maven", "/usr/share/maven", [])
]
mavenDesc.setInstallations(mavenInstallations as Maven.MavenInstallation[])
mavenDesc.save()

println "Maven configured successfully!"
