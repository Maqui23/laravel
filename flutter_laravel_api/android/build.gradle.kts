plugins {
    // Deja que Flutter decida la versión de estos
    id("com.android.application") apply false
    id("com.android.library") apply false
    
    // CAMBIA EL 1.8.22 POR EL 2.2.20
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    
    // Este es el que necesitamos para Firebase (Requisito del proyecto)
    id("com.google.gms.google-services") version "4.4.1" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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