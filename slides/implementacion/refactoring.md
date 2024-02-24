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

# REFACTORING

---

## Refactoring

Hacer _refactoring_ es hacer pequeñas transformaciones en el código que mantienen el sistema funcional, sin añadir nuevas funcionalidades.

> Refactoring is a __disciplined__ technique for restructuring an existing body of code, altering its internal structure without changing its __external__ behavior
>
> — [M. Fowler](http://www.refactoring.com/), www.refactoring.com
>
> A change made to the internal structure of the software to make it easier to understand and cheaper to modify without changing its observable behavior
>
> – [M. Fowler (2008): Refactoring...](bibliografia.md#refactoring)

---

### Motivos para hacer refactoring

- Duplicación de código
- Diseño no ortogonal
- Cambios (de requisitos, más conocimiento del problema)
- Uso del sistema (se descubre la imporancia de las cosas)
- Rendimiento
- Pasan todos los tests (es la oportunidad)

---

> __Lecturas recomendadas__
>  - Hunt & Thomas. [The Pragmatic Programmer](bibliografia.md#pragmatic), 2019. Capítulo 40: *Refactoring*
>  - McConnell. [Code Complete](bibliografia.md#codecomplete), 2004.

---

### Conceptos relacionados con el refactoring

- Deuda técnica
- _Clean code_ vs _dirty code_
- Tests unitarios y _Test-Driven Development_ (TDD)
- Tufos o _code smells_

> __Lecturas recomendadas__
>  - Refactoring Guru: [What is Refactoring?](https://refactoring.guru/refactoring/what-is-refactoring)
>  - Refactoring Guru: [Code Smells](https://refactoring.guru/refactoring/smells)
>  - Refactoring Guru: [Refactoring techniques](https://refactoring.guru/refactoring/techniques)

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Cuál es la primera razón para hacer refactoring?

---

### Ejemplos de refactoring

- __Código duplicado__
- Rutinas demasiado largas
- Bucles demasiado largos o demasiado anidados
- Clases poco cohesionadas
- Interfaz de una clase con un nivel de abstracción poco consistente
- Demasiados parámetros en una función
- Jerarquías de herencia en paralelo
- Muchas sentencias _case_ en paralelo
- Hay muchos cambios en una clase que tienden a estar compartimentalizados (afectan solo a una parte)
- Hay muchos cambios que requieren modificaciones en paralelo a varias clases
- Etc.

---

<!-- paginate: true -->

## CASO PRÁCTICO: Cálculo de nóminas

---

### Implementación de nóminas v0.1

```java
public class Empleado {
  Comparable id;
  String name;
  public Empleado(String id, String name) {
      this.id = id;
      this.name = name;
  }
  public void print() {
      System.out.println(id+" "+name);
  }
}
```

---

```java
public class Autonomo extends Empleado {
  String vatCode;
  public Autonomo(String id, String name, String vat) {
      this.id = id;
      this.name = name;
      this.vatCode = vat;
  }
  public void print() {
      System.out.println(id+" "+name+" "+vatCode);
  }
}
public class Prueba {
  public static void main(String[] args) {
    Empleado e = new Empleado("0001","Enrique");
    Empleado a = new Autonomo("0002","Ana","12345-A");
    e.print();  
    a.print();  
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

En la implementación anterior, ¿dónde hay código duplicado?

---

- Código duplicado en los constructores de las clases y subclases
- Refactorizar delegando hacia la superclase

---

### Implementación de nóminas v0.2

- Requisito: los trabajadores autónomos cobran por horas (no tienen un salario fijo bruto)
- Incluimos el método `computeMonthlySalary` para el cálculo de la nómina mensual

---

```java
public class Empleado {
  Comparable id;
  String name;
  float yearlyGrossSalary;
  public Empleado(String id, String name) {
      this.id = id;
      this.name = name;
  }
  void setSalary( float s ) { yearlyGrossSalary=s; }   
  public void print() {
      System.out.print(id+" "+name);
  }
  public float computeMonthlySalary() {
      return yearlyGrossSalary/12;
  }
}
```

---

```java
public class Autonomo extends Empleado {
  String vatCode;
  float workingHours;
  public Autonomo(String id, String name, String vat) {
      super(id,name);
      this.vatCode = vat;
      this.workingHours = 0.0;
  }
  public float computeMonthlySalary() {
      return workingHours*Company.getHourlyRate()*(1.0+Company.getVatRate());
  }
  @Override
  public void print() {
      super.print();
      System.out.print(" "+vatCode);
  }
}
```

---

```java
public class Prueba {
  public static void main(String[] args) {
    Empleado e = new Empleado("0001", "Enrique");
    Empleado a = new Autonomo("0002", "Ana", "12345-A");
    e.print();  System.out.println();
    a.print();  System.out.println();
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

¿Están descohesionadas las clases?

---

- ¿Todos los empleados deben tener un salario anual `yearlyGrossSalary` bruto?
  Los autónomos no...
- El método de cálculo del salario está descohesionado

---

### Implementación de nóminas v0.3

```java
public class Prueba {
  public static void main(String[] args) {
    Empleado e = new Plantilla("0001", "Pepe");
    e.setSalary(25000.0);
    Empleado a = new Autonomo("0002", "Ana", "12345-A");
    a.addWorkingHours(30.0);
    e.print(); System.out.println(" Salario: "+e.computeMonthlySalary()+" EUR");
    a.print(); System.out.println(" Salario: "+a.computeMonthlySalary()+" EUR");
  }
}
```

---

```java
public abstract class Empleado {
  /* ... */
  public abstract float computeMonthlySalary();
}

public class Plantilla extends Empleado {
  float yearlyGrossSalary;

  /* ... */
  float setSalary( float s ) { yearlyGrossSalary=s; }
  public float computeMonthlySalary() {
      return yearlyGrossSalary/12;
  }
}
```

---

```java
public class Autonomo extends Empleado {
  String vatCode;
  float workingHours;

  public Autonomo(String id, String name, String vat) {
      super(id,name);
      this.vatCode = vat;
      this.workingHours = 0.0;
  }
  
  public void addWorkingHours(float workingHours){
    this.workingHours += workingHours;
  }

  public float computeMonthlySalary() {
      return workingHours*Company.getHourlyRate()*(1.0+Company.getVatRate());
  }

  @Override
  public void print() {
      super.print();
      System.out.print(" "+vatCode);
  }
}
```

---

## Código duplicado

> **Lectura recomendada**
> - Hunt & Thomas. [The Pragmatic Programmer](bibliografia.md#pragmatic), 1999
> Capítulo *DRY—The Evils of Duplication*

### ¿Por qué no duplicar?

- Mantenimiento
- Cambios (no sólo a nivel de código)
- Trazabilidad

---

### Causas de la duplicación

1. __Impuesta__: No hay elección
2. __Inadvertida__: No me he dado cuenta
3. __Impaciencia__: No puedo esperar
4. __Simultaneidad__: Ha sido otro

### Principio DRY – *Don't Repeat Yourself!*

by [Hunt & Thomas (1999)](bibliografia.md#pragmatic)

> Copy and paste is a design error
>
> – McConnell (1998)

---

## 1. Duplicación impuesta

La gestión del proyecto así nos lo exige. Algunos ejemplos:

- Representaciones múltiples de la información:
    - Varias implementaciones de un TAD que necesita guardar elementos de distintos tipos, cuando el lenguaje no permite genericidad
    - El esquema de una BD configurado en la BD y en el código fuente a través de un [ORM](http://www.agiledata.org/essays/mappingObjects.html)
- Documentación del código:
    - Código incrustado en javadocs
- Casos de prueba:
    - Pruebas unitarias con jUnit
- Características del lenguaje:
    - C/C++ header files
    - IDL specs

---

### Cómo evitaba Java la duplicación en sus _containers_

Cuando el lenguaje no tenía capacidad de usar tipos genéricos (hasta el JDK 1.4), podría aparecer la necesidad de duplicar código a la hora de implementar un TAD contenedor, pues habría que repetir todo el código de manejo del TAD para cada tipo de elemento contenido.

Para evitarlo, Java usó un _workaround_: todas las clases en Java heredan de `Object`. Así una clase que implementara un TAD contenedor de elementos de otra clase, tan solo tenía que declarar los elementos contenidos de tipo `Object`.

Más tarde (a partir del JDK 1.5) introdujo los tipos genéricos y ya no era necesario usar dicho _workaround_ basado en `Object` para evitar la duplicación

---

### Técnicas de solución

- __Generadores de código__: para evitar duplicar representaciones múltiples de la información
- Herramientas de __ingeniería inversa__: para generar código a partir de un esquema de BD – v.g. [jeddict](https://jeddict.github.io/) para crear clases JPA, visualizar y modificar BDs y automatizar la generación de código Java EE.
- __Plantillas__: Tipos genéricos del lenguaje (Java, C++, TypeScript, etc.) o mediante un motor de plantillas – v.g. [Apache Velocity](http://velocity.apache.org/) template language ([VTL](http://velocity.apache.org/engine/2.0/user-guide.html#velocity-template-language-vtl-an-introduction))
- __Metadatos__: Anotaciones @ en Java, decoradores en TypeScript, etc.
- Herramientas de __documentación__ (v.g. [asciidoctor](http://asciidoctor.org/): [inclusión de ficheros](https://docs.asciidoctor.org/asciidoc/latest/directives/include/)).
- Herramientas de __[programación literaria](http://www.literateprogramming.com/)__
- Ayuda del __IDE__

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Cómo reducir la duplicación de código al programar pruebas unitarias?

---

### Property-based testing

- Herramientas de *property-based testing*, como [Hypothesis](https://pypi.org/project/hypothesis/) (python), [RapidCheck](https://github.com/emil-e/rapidcheck) (C++), [jqwik](https://jqwik.net/)  (Java) o [QuickCheck](https://en.wikipedia.org/wiki/QuickCheck) (originalmente para Haskell).

- Leer el Consejo nº 71 del libro de [Hunt & Thomas (2020)](bibliografia.md#pragmatic2).

---

#### Ejemplo de Hypothesis en Python

Ejemplo de property-based testing con [Hypothesis](https://pypi.org/project/hypothesis/) en Python:

  ```python
  from hypothesis import given
  import hypothesis.strategies as some

  @given(some.lists(some.integers()))
  def test_list_size_is_invariant_across_sorting(a_list):
    original_length = len(a_list)
    a_list.sort()
    assert len(a_list) == original_length

  @given(some.lists(some.text()))
  def test_sorted_result_is_ordered(a_list):
    a_list.sort()
    for i in range(len(a_list) - 1):
      assert a_list[i] <= a_list[i + 1]
  ```

---

## 2. Duplicación inadvertida

- Normalmente tiene origen en un diseño inapropiado.
- Fuente de numerosos problemas de integración.

### Ejemplo: código duplicado – versión 1

```java
  public class Line {
    public Point start;
    public Point end;
    public double length;
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


¿Dónde está la duplicación?

---

Realmente `length` ya está definido con `start`y `end`.

¿Mejor así...?

```java
  public class Line {
    public Point start;
    public Point end;
    public double length() {
       return start.distanceTo(end);
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

¿Es conveniente aplicar siempre DRY?

---

- A veces se puede optar por violar DRY por razones de rendimiento...
- [_Memoization_](https://en.wikipedia.org/wiki/Memoization): cachear los resultados de cómputos costosos

---

### Ejemplo: aplicando memoization – versión 2

```java
  public class Line {
    private boolean changed;
    private double length;
    private Point start;
    private Point end;

    public void setStart(Point p) { start = p; changed = true; }
    public void setEnd(Point p)   { end   = p; changed = true; }
    public Point getStart() { return start; }
    public Point getEnd() { return end; }
    public double getLength() {
       if (changed) {
          length = start.distanceTo(end);
          changed = false;
       }
       return length;
    }
  }
```

---

La técnica de memoization es menos problemática si queda dentro de los límites de la clase/módulo.

Otras veces no merece la pena violar DRY por rendimiento: ¡las cachés y los optimizadores de código también hacen su labor!

---

### Principio de acceso uniforme

> All services offered by a module should be available through a uniform notation, which does not betray whether they are implemented through storage or through computation
>
> [B. Meyer](bibliografia.md#meyer)

Conviene aplicar el principio de acceso uniforme para que sea más fácil añadir mejoras de rendimiento (v.g. caching)

---

#### Ejemplo: acceso uniforme en C# – versión 3

```csharp
public class Line {
  private Point Start;
  private Point End;
  private double Length;

  public Point Start {
    get { return Start; }
    set { Start = value; }
  }

  public Point End {
    get { return End; }
    set { Start = value; }
  }

  public double Length {
    get { return Start.distanceTo(End); }
  }
}
```

---

#### Ejemplo: acceso uniforme en Scala

Llamadas a métodos con paréntesis:

```scala
class Complejo(real: Double, imaginaria: Double) {
  def re() = real
  def im() = imaginaria
  override def toString() =
    "" + re() + (if (im() < 0) "" else "+") + im() + "i"
}

object NumerosComplejos {
  def main() : Unit = {
    val c = new Complejo(1.2, 3.4)
    println("Número complejo: " + c.toString())
    println("Parte imaginaria: " + c.im())
  }
}
```

---

Llamadas a métodos sin paréntesis, igual que si fueran atributos:

```scala
class Complejo(real: Double, imaginaria: Double) {
  def re = real
  def im = imaginaria
  override def toString() =
    "" + re + (if (im < 0) "" else "+") + im + "i"
}

object NumerosComplejos {
  def main() : Unit = {
    val c = new Complejo(1.2, 3.4)
    println("Número complejo: " + c)
    println("Parte imaginaria: " + c.im)
  }
}
```

---

## 3. Duplicación por impaciencia

- Los peligros del *copy&paste*
- "Vísteme despacio que tengo prisa" (_shortcuts make for long delays_). Ejemplos:
    - Meter el `main` de Java en cualquier clase
    - Fiasco del año 2000

---

## 4. Duplicación por simultaneidad

- No resoluble a nivel de técnicas de construcción
- Hace falta metodología, gestión de equipos + herramientas de comunicación
  - CI/CD (_Continuous Integration / Continuous Delivery)
  - Prácticas DevOps

---

## Reglas para hacer refactoring

Según Fowler:

1. No hacer refactoring y añadir funcionalidad al mismo tiempo
2. Disponer de buenos tests antes de empezar. Pasarlos a menudo.
3. Dar pasos cortos:
   - mover un campo de una clase a otra
   - dividir un método
   - renombrar una variable

Yo añado...

- Reflejar cada cambio en un _commit_ separado
