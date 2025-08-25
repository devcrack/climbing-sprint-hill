# Getting Started

### Reference Documentation

For further reference, please consider the following sections:

* [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
* [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/3.5.5/maven-plugin)
* [Create an OCI image](https://docs.spring.io/spring-boot/3.5.5/maven-plugin/build-image.html)
* [Spring Boot DevTools](https://docs.spring.io/spring-boot/3.5.5/reference/using/devtools.html)
* [Thymeleaf](https://docs.spring.io/spring-boot/3.5.5/reference/web/servlet.html#web.servlet.spring-mvc.template-engines)
* [Spring Web](https://docs.spring.io/spring-boot/3.5.5/reference/web/servlet.html)

### Guides

The following guides illustrate how to use some features concretely:

* [Handling Form Submission](https://spring.io/guides/gs/handling-form-submission/)
* [Building a RESTful Web Service](https://spring.io/guides/gs/rest-service/)
* [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)
* [Building REST services with Spring](https://spring.io/guides/tutorials/rest/)

### Maven Parent overrides

Due to Maven's design, elements are inherited from the parent POM to the
project POM.
While most of the inheritance is fine, it also inherits unwanted elements like
`<license>` and `<developers>` from the parent.
To prevent this, the project POM contains empty overrides for these elements.
If you manually switch to a different parent and actually want the inheritance,
you need to remove those overrides.

### Usar el mismo JDK en IDE y Terminal

Para asegurarte de que el proyecto use el mismo JDK tanto desde el IDE como desde la terminal:

- Opción rápida (macOS/Linux): usar el JDK del IDE automáticamente
  - Ejecuta: `bash scripts/mvnw-ide.sh clean test`
  - El script detecta el JDK de IntelliJ (JetBrains Runtime) en rutas comunes (App y Toolbox) y ejecuta `./mvnw` con ese JAVA_HOME.
  - Si no encuentra el del IDE, intenta usar Java 17 del sistema (`/usr/libexec/java_home -v 17` en macOS).

- Opción estándar: usar el wrapper de Maven del proyecto
  - En macOS/Linux: `./mvnw clean verify`
  - En Windows: `mvnw.cmd clean verify`
  - Nota: Esto usa el JDK que indique tu JAVA_HOME/Path del sistema.

- Alinear JAVA_HOME manualmente con el JDK del IDE
  - Comprueba el JDK que usa el IDE (IntelliJ IDEA: File > Project Structure > Project SDK = 17, y Settings > Build, Execution, Deployment > Build Tools > Maven > JDK for importer/runner).
  - En la terminal, exporta JAVA_HOME al mismo JDK (ejemplos):
    - macOS/Linux (bash/zsh):
      - `export JAVA_HOME=$(/usr/libexec/java_home -v 17)`
      - `export PATH="$JAVA_HOME/bin:$PATH"`
    - Windows (PowerShell):
      - `$env:JAVA_HOME = "C:\\Program Files\\Java\\jdk-17"`
      - `$env:Path = "$env:JAVA_HOME\\bin;" + $env:Path`

- Verifica la versión en ambos lados
  - `java -version` y `./mvnw -v` deben mostrar el mismo JDK.

- (Opcional recomendado) Validación automática
  - Añade el plugin Maven Enforcer con `requireJavaVersion` a 17 en el pom.xml para que falle el build si no usas el JDK correcto.

