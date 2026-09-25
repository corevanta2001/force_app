allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)
subprojects {
    val newSubBuildDir = newBuildDir.dir(project.name)
    layout.buildDirectory.value(newSubBuildDir)
}
subprojects {
    evaluationDependsOn(":app")
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
