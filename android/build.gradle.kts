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
    val project = this
    if (project.state.executed) {
        configureNamespace(project)
    } else {
        afterEvaluate {
            configureNamespace(project)
        }
    }
}

fun configureNamespace(project: Project) {
    if (project.hasProperty("android")) {
        val android = project.extensions.getByName("android")
        if (android is com.android.build.gradle.BaseExtension) {
            if (android.namespace == null) {
                android.namespace = "com.example.${project.name.replace("-", "_")}"
            }
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_21
                targetCompatibility = JavaVersion.VERSION_21
            }
        }
    }
    project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget("21"))
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
