allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Esto es opcional - solo si realmente necesitas cambiar el directorio de build
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    
    afterEvaluate {
        if (project.path != ":app") {
            evaluationDependsOn(":app")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}