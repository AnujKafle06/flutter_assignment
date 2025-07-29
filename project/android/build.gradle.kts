buildscript {
    val kotlin_version = "1.9.22"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.0.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        classpath("com.google.gms:google-services:4.3.15")
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Set build directory using File objects
rootProject.buildDir = file("../build")

// Configure subprojects
subprojects {
    project.buildDir = file("${rootProject.buildDir}/$name")
    project.evaluationDependsOn(":app")
}

// Register clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}