---
marp: true
title: Apuntes IISS
description: Apuntes de Implementación e Implantación de Sistemas Software
---

<!-- size: 16:9 -->
<!-- theme: default -->

<!-- paginate: false -->

<style>
h1 {
  text-align: center;
}
h2 {
  color: darkblue;
  text-align: center;
}
</style>

# INYECCIÓN DE DEPENDENCIAS

---

<!-- paginate: true -->

<style scoped>
p {
  text-align: center;
}
</style>

## CASO PRÁCTICO: Implementación de una orquesta (2)

---

### Implementación de Orquesta v.08

Retocamos un poco la implementación de la orquesta para introducir partituras...

```java
public class Partitura implements Iterable<String> {
  private String score;
  public Partitura(String score) {
    this.score = score;
  }
  public Iterator<String> iterator() {
    return Arrays.stream(score.split(" ")).iterator();
  }
}

public abstract class Instrumento {
    protected String nombre;
    protected Partitura partitura = new Partitura("G D7 C D7 G");

    public abstract String tocar(String nota);
    public String afinar() { return "Afinando "+nombre; }
    public String tocarPartitura() {
      StringBuffer sb = new StringBuffer();
      partitura.forEach( nota -> sb.append(tocar(nota)) );
      return sb.toString();
      //for (String nota: partitura)
      //  tocar(nota);
    }
}
```

---

```java
class Orquesta implements Iterable<Instrumento> {
  private Instrumentos instrumentos;
  public Orquesta() {
      instrumentos = new Instrumentos(3);
  }
  public boolean addInstrumento(Instrumento i) {
      return instrumentos.addInstrument(i);
  }
  public boolean removeInstrumento(Instrumento i) {
      return instrumentos.removeInstrument(i);
  }
  public Iterator<Instrumento> iterator() {
      return instrumentos.iterator();
  }
  public String tocar() {
      StringBuffer sb = new StringBuffer();
      for (Instrumento i: instrumentos)
        sb.append( i.tocarPartitura() );
      return sb.toString();
  }
  public String afinar(Instrumento i) {
    StringBuffer sb = new StringBuffer();
    return sb.append( i.afinar() ).toString();
  }
}
```

---

```java
class Viento extends Instrumento {
    public Viento(String nombre) {
      this.nombre = nombre;
    }
    public String tocar(String nota) { soplar(nota); return nota; }
    public void soplar() { System.out.println(nombre+" soplando "+partitura); }
    public void soplar(String nota) { System.out.println(nombre+" soplando "+nota); }
}

class Cuerda extends Instrumento {
    public Cuerda(String nombre) {
      this.nombre = nombre;
    }
    public String tocar(String nota) { rasgar(nota); return nota; }
    public void rasgar() { System.out.println(nombre+" rasgando "+partitura); }
    public void rasgar(String nota) { System.out.println(nombre+" rasgando "+nota); }
}

class Percusion extends Instrumento {
    public Percusion(String nombre) {
      this.nombre = nombre;
    }
    public String tocar(String nota) { golpear(nota); return nota; }
    public void golpear() { System.out.println(nombre+ "golpeando "+partitura); }
    public void golpear(String nota) { System.out.println(nombre+" golpeando "+nota); }
}
```

---

```java
public class Instrumentos implements Iterable<Instrumento> {
  private List instrumentos;
  public Instrumentos(int numero) {
    instrumentos = new ArrayList<Instrumento>(numero);
  }
  public Iterator<Instrumento> iterator() {
      return instrumentos.iterator();
  }
  public boolean addInstrument(Instrumento i) {
    return instrumentos.add(i);
  }
  public boolean removeInstrument(Instrumento i) {
    return instrumentos.remove(i);
  }
}
```

---
<style>
section > img {
  align-self: flex-start;
}
</style>

### Diagrama de clases

@startuml
class Partitura {
  score
}

abstract class Instrumento {
  nombre
  partitura
}

Instrumento <|-down- Viento
Instrumento <|-down- Cuerda
Instrumento <|-down- Percusion

Instrumento -r-> Partitura

Orquesta -r-> Instrumentos

Instrumentos *-d-> Instrumento

PruebaOrquesta .r.> Orquesta

PruebaOrquesta .r.> Instrumento

together{
  class PruebaOrquesta
  class Orquesta
  class Instrumentos
}

together{
  class Instrumentos
  class Instrumento
}
@enduml

---

### Dependencias de instrumento

```java
public class PruebaOrquesta {
    public static void main(String[] args) {
      Orquesta orquesta = new Orquesta();
      orquesta.addInstrumento(new Viento("trompeta"));
      orquesta.addInstrumento(new Cuerda("guitarra"));
      orquesta.addInstrumento(new Percusion("tambor"));
      for (Instrumento i: orquesta)
          System.out.println ( orquesta.afinar(i) );
      orquesta.tocar();
    }
}
```

Los `new` de `PruebaOrquesta` siguen introduciendo dependencias de `PruebaOrquesta` con respecto a los tipos concretos de `Instrumento`.

Si quisiéramos probar la orquesta con otros instrumentos, tendríamos que modificar la clase cliente que utiliza la Orquesta.

---
<style>
section > img {
  align-self: flex-start;
}
</style>

#### Diagrama de clases - Dependencias

@startuml
class Partitura {
  score
}

abstract class Instrumento {
  nombre
  partitura
}

Instrumento <|-down- Viento
Instrumento <|-down- Cuerda
Instrumento <|-down- Percusion

Instrumento -r-> Partitura

Orquesta -r-> Instrumentos

Instrumentos *-d-> Instrumento

PruebaOrquesta .r.> Orquesta

PruebaOrquesta .r.> Instrumento

PruebaOrquesta .right.> Viento #red
PruebaOrquesta .right.> Cuerda #red
PruebaOrquesta .right.> Percusion #red

together{
  class PruebaOrquesta
  class Orquesta
  class Instrumentos
}

together{
  class Instrumentos
  class Instrumento
}
@enduml

---

Por ejemplo, si programamos **casos de prueba unitaria** con _jUnit_ (versión 3):

```java
import junit.framework.TestCase;
import junit.framework.Assert;

public class OrquestaTest extends junit.framework.TestCase {
  public void testTocar() {
      Orquesta orquesta = new Orquesta();
      orquesta.addInstrumento(new Viento("trompeta"));
      orquesta.addInstrumento(new Cuerda("guitarra"));
      orquesta.addInstrumento(new Percusion("tambor"));
      assertNotNull(orquesta.tocar());
      assertsEquals(orquesta.tocar(),"GD7CD7G");
  }
}
```

---

### Problemas:

- Problema con la instanciación de instrumentos
- Cada vez que se prueba `Orquesta`, también se prueban las subclases de `Instrumento`.
- No se puede pedir a la orquesta que se comporte de otra forma (por ejemplo, un conjunto diferente de instrumentos)
- Tampoco se puede cambiar la partitura que queremos probar

---

### Solución: inyección de dependencias

- Proporcionar a la `Orquesta` el conjunto de intrumentos de los que depende
- Proporcionar a cada `Instrumento` la partitura con la que debe ejecutar

---

#### Opciones:

Dependencia `Instrumento` $\dashrightarrow$ `Partitura`:

- ¿Añadir un argumento `Partitura` a los constructores de las subclases de `Instrumento`?
- ¿Definir métodos `Instrumento::setPartitura(Partitura p)`?

Dependencia `Orquesta` $\dashrightarrow$ `Instrumento`:

- ¿Añadir un argumento `Instrumento` al constructor de la `Orquesta`?
- ¿Definir métodos `Orquesta::addInstrumento(Instrumento i)`?
  - Esto ya lo estamos haciendo en `PruebaOrquesta` y `OrquestaTest`
- ¿Y por qué no un método `Orquesta::setPartitura(Partitura p)`?

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Quién le añade los instrumentos a la orquesta?
¿Quién le pone el cascabel (partitura) al gato (instrumento)?
¿A qué gato (orquesta o instumento)?

---

## Framework DI

La __inyección de dependencias__ (DI) no suele hacerse de modo manual (programando una clase que lo haga), sino que se delega en una biblioteca especial (el framework DI) que lo hace, previa configuración.

El framework DI inyecta dependencias de forma universal, no de modo particular a un programa específico y a las clases que lo componen.

### Algunos frameworks de inyección de dependencias

- [Google guice](https://github.com/google/guice/wiki/GettingStarted)
- [Spring Framework](https://www.vogella.com/tutorials/SpringDependencyInjection/article.html)
- [Weld CDI](http://weld.cdi-spec.org/)
- [Eclipse RCP](https://wiki.eclipse.org/Eclipse4/RCP/Dependency_Injection)
---

### Inyección con Spring Framework

A través de un fichero de configuración `orquesta.xml` le indicamos los valores inyectables:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN"
  "http://www.springframework.org/dtd/spring-beans.dtd">
<beans>
  <bean id="trompeta"
    class="Viento"/>
  <bean id="violin"
    class="Cuerda"/>
  <bean id="tambor"
    class="Percusion"/>
  <bean id="viola"
    class="Cuerda"/>
```

---

```xml
  <bean id="cuarteto"
    class="Orquesta">
    <property name="instrumento1">
      <ref bean="trompeta"/>
    </property>
    <property name="instrumento2">
      <ref bean="violin"/>
    </property>
    <property name="instrumento3">
      <ref bean="viola"/>
    </property>
    <property name="instrumento4">
      <ref bean="tambor"/>
    </property>    
  </bean>
</beans>
```

---

La inyección de la dependencia concreta la hace el contenedor (_spring_ en este ejemplo):

```java
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.xml.XmlBeanFactory;

public class PruebaOrquesta {
  public static void main(String[] args) throws Exception {
    BeanFactory factory =
      new XmlBeanFactory(new FileInputStream("orquesta.xml"));
    Orquesta orquesta = (Orquesta)factory.getBean("cuarteto");
    for (Instrumento i: orquesta)
      orquesta.afinar(i);
    orquesta.tocar();
  }
}
```

---

### Beans

Un _bean_ es una clase/componente reutilizable en Java que tiene una interfaz bien definida, según una especificación estándar de Java, que permite a un contenedor gestionar su _ciclo de vida_ (crearlos, cambiarles valores de sus propiedades, destruirlos, etc.)

Los _beans_ son usados por muchos frameworks, entre otros Spring:

- [Spring Bean](https://www.baeldung.com/spring-bean)
- [Spring FactoryBean](http://www.baeldung.com/spring-factorybean)

Más info sobre [Spring DI](https://docs.spring.io/spring-framework/reference/core/beans/dependencies/factory-collaborators.html)

---

#### Ejemplo: Logger

También se puede inyectar la dependencia en el constructor.

```java hl_lines="5"
import java.util.logging.Logger;

public class MyClass {
  private final static Logger logger;
  public MyClass(Logger logger) {
      this.logger = logger;
      // write an info log message
      logger.info("This is a log message.")
  }
}
```

Un _contenedor_ de dependencias en el framework debe responsabilizarse de crear las instancias de `Logger` e inyectarlas en su sitio (normalmente vía _reflexión_ o _introspección_)

---

## Anotaciones

---

### Anotaciones @ en Java

JSR 330 es un estándar de Java para describir las dependencias de una clase con `@Inject` y otras anotaciones. Hay diversas implementaciones de [JSR 330](http://javax-inject.github.io/javax-inject/).

```java hl_lines="2 4 5"
public class MyPart {
  @Inject private Logger logger;
  // inject class for database access
  @Inject private DatabaseAccessClass dao;
  @Inject
  public void createControls(Composite parent) {
    logger.info("UI will start to build");
    Label label = new Label(parent, SWT.NONE);
    label.setText("Eclipse 4");
    Text text = new Text(parent, SWT.NONE);
    text.setText(dao.getNumber());
  }
}
```

La clase `MyPart` sigue usando `new` para ciertos elementos de la interfaz. Esto significa que no pensamos reemplazarlos ni siquiera para hacer pruebas.

---

### Otra manera de inyectar dependencias

jUnit 4 usa anotaciones para programar casos de prueba:

```java
import org.junit.*;
import static org.junit.Assert.*;

public class OrquestaTest { // no hace falta extends
  private Orquesta orquesta;
  @Before
  protected void setUp() {
      Orquesta orquesta = new Orquesta();
      orquesta.addInstrumento(new Viento("trompeta"));
      orquesta.addInstrumento(new Cuerda("guitarra"));
      orquesta.addInstrumento(new Percusion("tambor"));
  }
  @After
  protected void tearDown() {
      orquesta = null;
  }
  @Test
  public void testTocar() {
      assertNotNull(orquesta.tocar());
      assertsEquals(orquesta.tocar(),"GD7CD7G");
  }
}
```

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Es necesario usar la inyección de dependencias para especificar las _partituras_ con las que deben funcionar los instrumentos de la _orquesta_?

<!--
Sólo si queremos que la orquesta pueda tocar con diferentes partituras, o si queremos probar la orquesta con diferentes partituras.
-->

---

## CASO PRÁCTICO: Implementación de comparadores (2)

---

### Ejercicio: Identificador de BankAccount con inyección de dependencias

Supongamos que queremos obtener un listado ordenado por fecha de creación de todas las cuentas bancarias.

¿Cómo afecta este cambio a la versión de `BankAccount` ya implementada con JDK 1.5?

Resolvemos mediante inyección de dependencias...

---

#### Con herencia de interfaz y delegación

`BankAcccount.java`:

```java
import java.util.*;
import java.io.*;
import java.time.*;

public final class BankAccount implements Comparable<BankAccount> {
  private final String id;
  private LocalDate creationDate;
  private Comparator comparator;

  public BankAccount(String number) {
    this.id = number;
    comparator = new BankAccountComparatorById();
  }
  public LocalDate getCreationDate() {
    return creationDate;
  }
  public void setCreationDate(LocalDate date) {
    this.creationDate = date;
  }
  public String getId() {
    return id;
  }
```

---

```java
  public void setComparator(Comparator cmp) {
    comparator = cmp;
  }
  @Override
  public int compareTo(BankAccount other) {
    if (this == other)
      return 0;
    assert this.equals(other) : "compareTo inconsistent with equals.";
    return comparator.compare(this, other);
  }
  @Override
  public boolean equals(Object other) {
    if (this == other)
      return true;
    if (!(other instanceof BankAccount))
      return false;
    BankAccount that = (BankAccount) other;
    return this.id.equals(that.getId());
  }
  @Override
  public String toString() {
    return id.toString();
  }
}
```

---

`BankAcccountComparatorById.java`:

```java
import java.util.*;

class BankAccountComparatorById implements Comparator<BankAccount> {
    public int compare(BankAccount o1, BankAccount o2) {
        return o1.getId().compareTo(o2.getId());
    }
}
```

`BankAcccountComparatorByCreationDate.java`:

```java
import java.util.*;

class BankAccountComparatorByCreationDate implements Comparator<BankAccount> {
    public int compare(BankAccount o1, BankAccount o2) {
        return o1.getCreationDate().compareTo(o2.getCreationDate());
    }
}
```

---

#### Con inyección de dependencias

El motor de inyección de dependencias (por ejemplo, Spring) inyectaría la clase concreta `BankAccountComparatorBy...` de alguna de estas formas:

- Inyección a través del __constructor__: la clase inyectora suministra la dependencia a través del constructor de la clase dependiente.

- Inyección a través de __propiedades__: la clase inyectora suministra la dependenca a través de un método _setter_ de la clase dependiente.

- Inyección a través de __métodos (API)__: la clase inyectora suministra la dependencia a través de una API determinada para la que está preparada (construida/configurada) la clase dependiente.

---

#### Creación de anotaciones

Ahora podría definirse una anotación del tipo `@comparator(BankAccountComparatorById.className)` o `@compareById` que inyecte a `BankAccount` una dependencia `BankAccountComparatorById` en `BankAccount.comparator`.

---

### Inyección de dependencias con anotaciones

- Java: Ejemplo de cómo [crear una anotación a medida en Java](https://www.baeldung.com/java-custom-annotation)
- Typescript: las anotaciones se llaman **decorators** y son más sencillas de programar

<!--

---

#### Ejemplo de retención de anotaciones en Java

Here we will be creating 3 annotations with RetentionPolicy as SOURCE, CLASS, & RUNTIME

Obtaining the array of annotations used to annotate class A, B, and C. Array a and b will be empty as their annotation are attached before runtime while array c will contain the RuntimeRetention annotation as it was marked with RUNTIME retention policy

Since the class C is annotated with an annotation which which has retention policy as runtime so it can be accessed during runtime while annotations of other two classes are discarded before runtime so they can't be accessed

```java
import java.lang.annotation.Annotation;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
```

---

```java
@Retention(RetentionPolicy.SOURCE)
@interface SourceRetention
{
   String value() default "Source Retention";
}

@Retention(RetentionPolicy.CLASS)
@interface ClassRetention
{
   String value() default "Class Retention";
}

@Retention(RetentionPolicy.RUNTIME)
@interface RuntimeRetention
{
   String value() default "Runtime Retention";
}
```

---

```java
// Annotating classes A, B, and C
// with our custom annotations

@SourceRetention
class A {
}

@ClassRetention
class B {
}

@RuntimeRetention
class C {
};
```

---

```java
public class RetentionPolicyDemo {
   public static void main(String[] args)
   {
      Annotation a[] = new A().getClass().getAnnotations();
      Annotation b[] = new B().getClass().getAnnotations();
      Annotation c[] = new C().getClass().getAnnotations();

      // Printing the number of retained annotations of
      // each class at runtime
      System.out.println( "Number of annotations attached to "
         + "class A at Runtime: " + a.length);

      System.out.println("Number of annotations attached to "
         + "class B at Runtime: " + b.length);

      System.out.println("Number of annotations attached to "
         + "class C at Runtime: " + c.length);

      System.out.println("Annotation attached to class C: " + c[0]);
   }
}
```

-->