java-example-gradle-local-remote
================================

This project illustrates some subtle
differences between local ("file://")
and remote ("http://") maven repositories
within gradle projects.

TLDR
----

With local maven repositories,
dynamic gradle dependencies are always updated.
With remote maven repositories, they
are updated only once a day.

Prerequisites
-------------

- jdk21

```sh
$ ./gradlew --version
------------------------------------------------------------
Gradle 8.11.1
------------------------------------------------------------

Build time:    2024-11-20 16:56:46 UTC
Revision:      481cb05a490e0ef9f8620f7873b83bd8a72e7c39

Kotlin:        2.0.20
Groovy:        3.0.22
Ant:           Apache Ant(TM) version 1.10.14 compiled on August 16 2023
Launcher JVM:  21.0.1 (Oracle Corporation 21.0.1+12-29)
Daemon JVM:    /home/uli/Software/jdk-21.0.1 (no JDK specified, using current Java home)
OS:            Linux 6.8.0-52-generic amd64
```

Populate Maven Repository
-------------------------

```sh
$ rm -rf maven-repository
$  ./create-maven-repository.sh

> Task :publishJavaPublicationToLocal-registryRepository
Publishing cool.heller.uli:hello-world:0.8.0 to file:/home/uli/git/github/uli-heller/java-example-gradle-local-remote/maven-repository

BUILD SUCCESSFUL in 717ms
5 actionable tasks: 5 executed

> Task :publishJavaPublicationToLocal-registryRepository
Publishing cool.heller.uli:hello-world:0.9.0 to file:/home/uli/git/github/uli-heller/java-example-gradle-local-remote/maven-repository/

BUILD SUCCESSFUL in 546ms
5 actionable tasks: 4 executed, 1 up-to-date

> Task :publishJavaPublicationToLocal-registryRepository
Publishing cool.heller.uli:hello-world:0.9.1 to file:/home/uli/git/github/uli-heller/java-example-gradle-local-remote/maven-repository/

BUILD SUCCESSFUL in 547ms
5 actionable tasks: 4 executed, 1 up-to-date
```

Populates the maven repository with versions
0.8.0, 0.9.0 and 0.9.1 of "cool.heller.uli:hello-world".
You'll have to do so serveral times!

Using Local Package Registry
----------------------------

- Verify: There is a "file://" url for the maven repository
  ```sh
  $ grep maven-repository build.gradle|grep -v "^\s*//"
          url("file://${projectDir}/maven-repository")
  ```
- Populate maven repository:
  ```sh
  rm -rf maven-repository
  ./create-maven-repository.sh
  ```
- Build the project: `./gradlew --refresh-dependencies build`
- Examine the outcome:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.1-plain.jar
- Create an additional version: `./create-version.sh hello-world 0.9.2`
- Rebuild the project without "--refresh-dependencies": `./gradlew build`
- Examine the outcome:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.2-plain.jar
- Note: The latest version is used!

Using Remote Package Registry
-----------------------------

- Start webserver: `jwebserver --port 8888 &`
- Change the url for the maven repository:
  - From: `url("file://${projectDir}/maven-repository")`
  - To: `url("http://localhost:8888/maven-repository")`
- Populate maven repository:
  ```sh
  rm -rf maven-repository
  ./create-maven-repository.sh
  ```
- Build the project: `./gradlew --refresh-dependencies build`
- Examine the outcome:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.1-plain.jar
- Create an additional version: `./create-version.sh hello-world 0.9.2`
- Rebuild the project without "--refresh-dependencies": `./gradlew build`
- Examine the outcome:
  - `unzip -v build/libs/java-example-gradle-local-remote-0.0.2.jar|grep hello`
  - hello-world-0.9.1-plain.jar
- Note: The additional version is not used - the initial version
  remains within the outcome!
