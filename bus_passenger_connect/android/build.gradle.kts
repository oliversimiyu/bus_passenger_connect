allprojects {
    repositories {
        maven { url = uri("/home/codename/CascadeProjects/bus-passenger-connect/maven_local") }
        google()
        mavenCentral()
        jcenter() // Adding for compatibility with older dependencies
    }
    
    // Use offline mode to avoid network requests
    configurations.all {
        resolutionStrategy {
            cacheChangingModulesFor(0, "seconds")
            cacheDynamicVersionsFor(0, "seconds")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
