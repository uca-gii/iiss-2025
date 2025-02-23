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

# DELEGACIÓN

---

<!-- paginate: true -->

## CASO PRÁCTICO: Implementación de una orquesta

---

### Versión inicial: Orquesta v0.1

Criticar la solución siguiente (parte 1):

```java
  abstract class Instrumento {
      public void tocar() { }
      public static void afinarInstrumento(Instrumento i)
      {
         // Afinar en funcion del tipo de i
         if (i instanceof Viento)
            afinarViento(i);
         else if (i instanceof Cuerda)
            afinarCuerda(i);
         // Probar que esta afinado
         i.tocar();  
      }
      public static void afinarViento(Viento i)
      { System.out.println("afinal soplido"); }

      public static void afinarCuerda(Cuerda i)
      { System.out.println("afinar rasgado"); }
  }
```

---

```java
  class Viento extends Instrumento {
      public void tocar() { soplar(); }
      public void afinar() { System.out.println("afinar soplido"); }
      public void soplar() { System.out.println("soplar"); }
  }

  class Cuerda extends Instrumento {
      public void tocar() { rasgar(); }
      public void afinar() { System.out.println("afinar rasgado"); }
      public void rasgar() { System.out.println("rasgar"); }
  }
```

---

```java
  public class Orquesta {
    ArrayList<Instrumento> instrumentos;
    public Orquesta() {
      instrumentos = new ArrayList<Instrumento>(3); }
    public void tocar() {
       for (int i=0; i<instrumentos.size(); i++)
         instrumentos.get(i).tocar();
    }
    public static void main(String[] args) {
      instrumentos.add(new Viento());
      instrumentos.add(new Cuerda());
      for (int i=0; i<instrumentos.size(); i++)
         Instrumento.afinarInstrumento(
                instrumentos.get(i));
      tocar();
    }
  }
```

---

#### Críticas a la Orquesta v0.1

- __Acoplamiento__: método `static`
- __Cohesión__: ubicación de `main`

---

### Implementación alternativa: Orquesta v0.2

Usar polimorfismo. Seguir criticando la implementación...

```java
  class Orquesta {
    ArrayList<Instrumento> instrumentos;
    public Orquesta() {
        instrumentos = new ArrayList<Instrumento>(3);
    }
    public void tocar() {
       for (int i=0; i<instrumentos.size(); i++)
         instrumentos.get(i).tocar();
    }
    public void afinar(Instrumento i) {
      i.afinar();  // Metodo polimorfico
      i.tocar();   // Prueba de que esta afinado
    }
  }
```

---

```java
  public class PruebaOrquesta {
     public static void main(String[] args) {
        Orquesta orquesta = new Orquesta();
        orquesta.instrumentos.add(new Viento());
        orquesta.instrumentos.add(new Cuerda());
        orquesta.instrumentos.add(new Percusion());
        for (int i=0; i<instrumentos.size(); i++)
           orquesta.afinar(orquesta.instrumentos.get(i));
        orquesta.tocar();
     }
  }
```

---

```java
  abstract class Instrumento {
      public void tocar() { };
      public void afinar() { };
  }

  class Viento extends Instrumento {
      public void tocar() { soplar(); }
      public void afinar() { System.out.println("afinar soplido"); }
      public void soplar() { System.out.println("soplar"); }
  }

  class Cuerda extends Instrumento {
      public void tocar() { rasgar(); }
      public void afinar() { System.out.println("afinar rasgado"); }
      public void rasgar() { System.out.println("rasgar"); }
  }

  class Percusion extends Instrumento {
      public void tocar() { golpear(); }
      public void afinar() { System.out.println("afinar golpeado"); }
      public void golpear() { System.out.println("golpear"); }
  }
```

---

#### Críticas a la Orquesta v0.2

- __Encapsulación__: visibilidad de `Orquesta::instrumentos` (en C++ sería `friend`)
- __Encapsulación__: método `add`
- __Flexibilidad__: la implementación `Orquesta::instrumentos` puede variar, pero no hay colección (agregado) en quien confíe `Orquesta` por delegación.

---

### Implementación alternativa: Orquesta v0.3

Delegar las altas/bajas de `Instrumento` en la colección (agregado) de `Orquesta`:

```java
  class Orquesta {

    protected ArrayList<Instrumento> instrumentos;

    public Orquesta() {
        instrumentos = new ArrayList<Instrumento>(3);
    }
    public boolean addInstrumento(Instrumento i) {
       return instrumentos.add(i);
    }
    public boolean removeInstrumento(Instrumento i) {
       return instrumentos.remove(i);
    }
    public void tocar() {
       for (int i=0; i<instrumentos.size(); i++)
         instrumentos.get(i).tocar();
    }
    public void afinar(Instrumento i) {
      i.afinar();
      i.tocar(); // Prueba de que esta afinado
    }
  }
```

---

```java
  public class PruebaOrquesta {
     public static void main(String[] args) {
        Orquesta orquesta = new Orquesta();
        orquesta.addInstrumento(new Viento());
        orquesta.addInstrumento(new Cuerda());
        orquesta.addInstrumento(new Percusion());
        for (int i=0; i<orquesta.instrumentos.size(); i++)
           orquesta.afinar(orquesta.instrumentos.get(i));
        orquesta.tocar();
     }
  }
```

---

#### Críticas a la Orquesta v0.3:

- __Acoplamiento__: `PruebaOrquesta` conoce la implementación basada en un `ArrayList` de la colección de instrumentos de la orquesta.
- __Variabilidad__: ¿La colección de instrumentos será siempre lineal?

---

### Implementación alternativa: Orquesta v0.4

Definir una __interfaz__ para iterar en la colección de instrumentos:

```java
  class Orquesta {
    protected List<Instrumento> instrumentos;
    public Orquesta() {
       instrumentos = new ArrayList<Instrumento>(3);
    }
    public boolean addInstrumento(Instrumento i) {
       return instrumentos.add(i);
    }
    public boolean removeInstrumento(Instrumento i) {
       return instrumentos.remove(i);
    }
    public void tocar() {
       for (Iterator<Instrumento> i = instrumentos.iterator(); i.hasNext(); )
          i.next().tocar();
    }
    public void afinar(Instrumento i) {
       i.afinar();
       i.tocar(); // Prueba de que esta afinado
    }
  }
```

---

```java
  public class PruebaOrquesta {
     public static void main(String[] args) {
        Orquesta orquesta = new Orquesta();
        orquesta.addInstrumento(new Viento());
        orquesta.addInstrumento(new Cuerda());
        orquesta.addInstrumento(new Percusion());
        for (Iterator<Instrumento> i = orquesta.instrumentos.iterator(); i.hasNext(); )
           orquesta.afinar(i.next());
        orquesta.tocar();
     }
  }
```

---

#### Críticas a la Orquesta v0.4

- __Ocultación__: el atributo `instrumentos` sigue sin ser privado.

Rehacemos la implementación, aprovechando que aparece una nueva versión del lenguaje (Java JDK 1.5) que permite iterar haciendo un __*for each*__ sobre una colección que implemente la interfaz `Iterable`. 

---

### Implementación alternativa: Orquesta v0.5

Usando delegación + interfaces y el _for each_ de Java 1.5. Criticar...

```java
  class Orquesta {
    private List<Instrumento> instrumentos;
    public Orquesta() {
       instrumentos = new ArrayList<Instrumento>(3);
    }
    public boolean addInstrumento(Instrumento i) {
       return instrumentos.add(i);
    }
    public boolean removeInstrumento(Instrumento i) {
       return instrumentos.remove(i);
    }
    public List<Instrumento> instrumentos() {
        return instrumentos;
    }
    public void tocar() {
       for (Instrumento i: instrumentos)
          i.tocar();
    }
    public void afinar(Instrumento i) {
       i.afinar();
       i.tocar(); // Prueba de que esta afinado
    }
  }
```

---

```java
  public class PruebaOrquesta {
     public static void main(String[] args) {
        Orquesta orquesta = new Orquesta();
        orquesta.addInstrumento(new Viento());
        orquesta.addInstrumento(new Cuerda());
        orquesta.addInstrumento(new Percusion());
        for (Instrumento i: orquesta.instrumentos())
           orquesta.afinar(i);
        orquesta.tocar();
     }
  }
```

---

#### Críticas a la Orquesta v0.5:

- __Ocultación__: la interfaz del método `instrumentos()` sigue expuesta: el cliente sabe que devuelve una `List`.
- Hemos ocultado un poco la implementación de `instrumentos` (que es una `List`), pero ¿conviene saber que es una `List`? Quizá no hemos ocultado lo suficiente.

---

#### Implementación alternativa: Orquesta v0.6

Nos quedamos sólo con lo que nos interesa de la Orquesta: que es una colección iterable.

Eliminamos lo que no nos interesa: el resto de elementos de la interfaz `List` que explican la forma lineal de almacenar los instrumentos.

---

```java
  class Orquesta implements Iterable<Instrumento> {
    private List<Instrumento> instrumentos;
    public Orquesta() {
       instrumentos = new ArrayList<Instrumento>(3);
    }
    public boolean addInstrumento(Instrumento i) {
       return instrumentos.add(i);
    }
    public boolean removeInstrumento(Instrumento i) {
       return instrumentos.remove(i);
    }
    public Iterator<Instrumento> iterator() {
       return instrumentos.iterator();
    }
    public void tocar() {
       for (Instrumento i: this)
          i.tocar();
    }
    public void afinar(Instrumento i) {
      i.afinar();
      i.tocar(); // Prueba de que esta afinado
    }
  }
```

---

```java
  public class PruebaOrquesta {
     public static void main(String[] args) {
        Orquesta orquesta = new Orquesta();
        orquesta.addInstrumento(new Viento());
        orquesta.addInstrumento(new Cuerda());
        orquesta.addInstrumento(new Percusion());
        for (Instrumento i: orquesta)
           orquesta.afinar(i);
        orquesta.tocar();
     }
  }
```

---

### Implementación alternativa: Orquesta v0.7

Supongamos que queremos sustituir la implementación basada en una `List` por otra (quizá más eficiente) basada en un `Map`.

Consultar la interfaz de `Map`:

- Interfaz [`java.util.Map`](http://docs.oracle.com/javase/6/docs/api/java/util/Map.html) de Java 6:

- Interfaz [`java.util.Map<K,V>`](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/Map.html) de Java 11:

---

`Map` no implementa `Iterable` (!)

Existe una cierta tensión proveedor-cliente en la **frontera** de la interfaz

- Los proveedores de packages y frameworks quieren ampliar aplicabilidad
- Los clientes quieren una interfaz centrada en sus necesidades particulares

Si construimos un `Map` y lo pasamos...

- Ninguno de los receptores deberá poder borrar algo del map. Pero ¡hay un `clear()` en el `Map`!
- Algunos de los métodos de `Map` esperan un `Object`: `containsKey(Object key)`, `containsValue(Object value)`

---

¿La interfaz `Map` es siempre satisfactoria? ¿seguro que no va a cambiar?

- JDK < 5.0:

```java
  Map sensors = new HashMap();
  sensors.put(1, new Sensor());
  sensors.put(2, new Sensor());
  ...
  Sensor s = (Sensor)sensors.get(sensorId);
```

- JDK >= 5.0:

```java
  Map<Integer,Sensor> sensors = new HashMap<Integer,Sensor>();
  sensors.put(1, new Sensor());
  sensors.put(2, new Sensor());
  ...
  Sensor s = sensors.get(sensorId);
```

---

__Conclusión__: `Map<Integer,Sensor>` ofrece más de lo que necesitamos

```java
  public class Sensors {
    private Map sensors = new HashMap();
    public Sensor getById(String id) {
      return (Sensor) sensors.get(id);
    }
    //...
  }
```

- La interfaz `Map` queda oculta en `Sensors`
- Se filtran los métodos que no nos sirven
- Más fácil de hacer evolucionar sin impacto en el resto de la aplicación
- El casting queda confinado en la clase `Sensors`, que es más seguro

---

Así que proponemos esta implementación de la Orquesta v0.7:

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
  public void tocar() {
      for (Instrumento i: instrumentos)
        i.tocar();
  }
  public void afinar(Instrumento i) {
    i.afinar();
    i.tocar(); // Prueba de que esta afinado
  }
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

```java
public class PruebaOrquesta {
    public static void main(String[] args) {
      Orquesta orquesta = new Orquesta();
      orquesta.addInstrumento(new Viento());
      orquesta.addInstrumento(new Cuerda());
      orquesta.addInstrumento(new Percusion());
      for (Instrumento i: orquesta)
          orquesta.afinar(i);
      orquesta.tocar();
    }
}
```

Esta implementación sí que podemos adaptarla más fácilmente para cambiar el `List` por un `Map`, pues la responsabilidad de ser iterable ha quedado confinada en `Instrumentos`, que desacopla `Orquesta` y la implementación elegida (`List`, `Map`, etc.) para la colección de instrumentos.

---

## Delegación

Delegación _en horizontal_ hacia otras clases cuya interfaz es bien conocida

- Los objetos miembro __delegados__ son cambiables en tiempo de ejecución sin afectar al código cliente ya existente
- Alternativa más flexible que la herencia. Ejemplo: `Cola extends ArrayList` implica que una cola va a implementarse como un `ArrayList` para toda la vida, sin posibilidad de cambio en ejecución

---

### Composición vs. Herencia

- **Composición** (delegación _en horizontal_)
    - Útil cuando hacen falta las características de una clase existente dentro de una nueva, _pero no su interfaz_.
    - Los objetos miembro privados pueden cambiarse en tiempo de ejecución.
    - Los cambios en el objeto miembro no afectan al código del cliente.

- **Herencia** (delegación _en vertical_)
    - Útil para hacer una versión especial de una clase existente, reutilizando su interfaz.
    - La relación de herencia en los lenguajes de programación _suele ser_ __estática__ (definida en tiempo de compilación) y no __dinámica__ (que pueda cambiarse en tiempo de ejecución).

---

## CASO PRÁCTICO: Implementación de comparadores

---

### Comparadores

- Un requisito habitual es implementar formas de **comparación** entre objetos de un mismo tipo.
- El criterio de comparación más habitual es usar un **identificador**
- A veces es necesario comparar los objetos en función de otros criterios (por ejemplo, para ordenar una colección)

¿Cómo se proporcionan esos criterios?

Cada lenguaje tiene sus mecanismos de implementación...

---

#### Comparadores: Implementación en Java

##### Implementación por herencia

`java.lang.Comparable` es una interfaz implementada por `String`, `File`, `Date`, etc. y todas las llamadas _clases de envoltura_ del JDK (i.e. `Integer`, `Long`, etc.)

#####  Métodos de la interfaz `Comparable`

```java
// JDK 1.4
public interface Comparable {
  public int compareTo(Object o); //throws ClassCastException
}
```

```java
// JDK 1.5
public interface Comparable<T> {
  public int compareTo(T o); //throws ClassCastException
}
```

---

#####  Invariantes

- Anticonmutativa:
  
  `sgn(x.compareTo(y)) = -sgn(y.compareTo(x))`

- Transitividad:

  `(x.compareTo(y)>0 and y.compareTo(z)>0)` $\rightarrow$ `x.compareTo(z)>0`

  `x.compareTo(y)=0` $\rightarrow$ `sgn(x.compareTo(z))=sgn(y.compareTo(z))` $\forall$ `z`

- Consistencia con `equals` (no obligatoria):

  `(x.compareTo(y)=0)` $\leftarrow$ `(x.equals(y))`

---

####  Identificador de BankAccount: Implementación en Java ≥ 1.5

- Utilizando _templates_ (**polimorfismo paramétrico**)
- Delegar en `compareTo` y `equals` del tipo de id _envuelto_ (e.g. `String`)

---

```java 
import java.util.*;
import java.io.*;

public final class BankAccount implements Comparable<BankAccount> {
  private final String id;
  public BankAccount (String number)  {
    this.id = number;
  }
  public String getId() { return id; }
  @Override
  public int compareTo(BankAccount other) {
    if (this == other) return 0;
    assert this.equals(other) : "compareTo inconsistent with equals.";
    return this.id.compareTo(other.getId());
  }
  @Override
  public boolean equals(Object other) {
    if (this == other) return true;
    if (!(other instanceof BankAccount)) return false;
    BankAccount that = (BankAccount)other;
    return this.id.equals(that.getId());
   }
  @Override
  public String toString() {
    return id.toString();
  }
}
```

---

##### Identificador de BankAccount: Implementación en Java ≤ 1.4

- No hay plantillas (polimorfismo paramétrico).
- La genericidad se consigue con `Object`. Hay que hacer casting.
- Cuidado con `Boolean` que no implementa `Comparable` en JDK 1.4

---

```java
import java.util.*;
import java.io.*;

public final class BankAccount implements Comparable {
  private final String id;
  public BankAccount (String number)  {
    this.id = number;
  }
  public String getId() { return id; }
  public int compareTo(Object other) {
    if (this == other) return 0;
    assert (other instanceof BankAccount) : "compareTo comparing objects of different type";
    BankAccount that = (BankAccount)other;
    assert this.equals(that) : "compareTo inconsistent with equals.";
    return this.id.compareTo(that.getId());
  }
  public boolean equals(Object other) {
    if (this == other) return true;
    if (!(other instanceof BankAccount)) return false;
    BankAccount that = (BankAccount)other;
    return this.id.equals(that.getId());
  }
  public String toString() {
      return id.toString();
  }
}
```

---

##### Implementación por composición/delegación

Cuando una clase hereda de una clase concreta que implementa `Comparable` y le añade un campo significativo para la comparación, no se puede construir una implementación correcta de `compareTo`. La única alternativa entonces es la composición en lugar de la herencia.

Una alternativa (no excluyente) a implementar `Comparable` es pasar un `Comparator` como parámetro (se prefiere __composición__ frente a __herencia__):

---

- Si `BankAccount` implementa `Comparable`:

```java
class BankAccountComparator implements java.util.Comparator<BankAccount> {
    public int compare(BankAccount o1, BankAccount o2) {
        return o1.compareTo(o2);
    }
}
```

- Si `BankAccount` no implementa `Comparable`:

```java
class BankAccountComparator implements java.util.Comparator<BankAccount> {
    public int compare(BankAccount o1, BankAccount o2) {
        return compare(o1.getId(), o2.getId());
    }
}
```

---

### Comparadores: Implementación en Scala

En Scala se puede implementar el equivalente a la interfaz `Comparable` de Java mediante _traits_:

```scala
object MiApp {
  def main(args: Array[String]) : Unit = {
    val f1 = new Fecha(12,4,2009)
    val f2 = new Fecha(12,4,2019)
    println(s"$f1 es posterior a $f2? ${f1>=f2}")
  }
}

trait Ord {
  def < (that: Any): Boolean 
  def <=(that: Any): Boolean = (this < that) || (this == that)
  def > (that: Any): Boolean = !(this <= that)
  def >=(that: Any): Boolean = !(this < that)
}
```

---

```scala
class Fecha(d: Int, m: Int, a: Int) extends Ord {
  def anno = a
  def mes = m
  def dia = d
  override def toString(): String = s"$dia-$mes-$anno"
  override def equals(that: Any): Boolean =
    that.isInstanceOf[Fecha] && {
      val o = that.asInstanceOf[Fecha]
      o.dia == dia && o.mes == mes && o.anno == anno
    }
  def <(that: Any): Boolean = {
    if (!that.isInstanceOf[Fecha])
      sys.error("no se puede comparar" + that + " y una fecha")
    val o = that.asInstanceOf[Fecha]
    (anno < o.anno) ||
    (anno == o.anno && (mes < o.mes ||
                       (mes == o.mes && dia < o.dia)))
  }  
}
```

---

## Mixins

---

Un __mixin__ es un módulo/clase con métodos disponibles para otros módulos/clases _sin tener que usar la herencia_

- Los mixin son un mecanismo de **reutilización de código** sin herencia
- Es una __alternativa__ a la herencia múltiple
- Incluye una __interfaz__ con métodos ya implementados
- No se heredan sino que se __incluyen__
- Un mixin es una (sub)clase, luego define un comportamiento y un __estado__
- Es una forma de implementar la __inversión de dependencias__

¿Qué lenguajes tienen mixins?

---

### Ruby modules

En Ruby los mixins se implementan mediante módulos (`module`).

- Un módulo no puede tener instancias (porque no es una clase)
- Un módulo puede incluirse (`include`) dentro de la definición de una clase

---

### Comparadores: Implementación en Ruby

Una manera de implementar un `Comparable` en ruby mediante el __módulo__ [Comparable](https://ruby-doc.org/core-2.2.3/Comparable.html):

- La clase que incluye el módulo `Comparable` tiene que implementar:

  - el método `<=>`: es un método que incluye los siguientes operadores/métodos: `<, <=, ==, >, >=, between?` 
  - el atributo-criterio de comparación

- En `x <=> y`, `x` es el receptor del mensaje/método e `y` es el argumento

---

```ruby
class Student
  include Comparable
  attr_accessor :name, :score

  def initialize(name, score)
    @name = name
    @score = score
  end

  def <=>(other)
    @score <=> other.score
  end
end

s1 = Student.new("Peter", 100)
s2 = Student.new("Jason", 90)
s3 = Student.new("Maria", 95)

s1 > s2 #true
s1 <= s2 #false
s3.between?(s1,s2) #true
```

---

### Scala Traits

Un __trait__ es una forma de separar las dos principales responsabilidades de una clase: definir el __estado__ de sus instancias y definir su __comportamiento__.

- Las clases y los objetos en Scala pueden extender un `trait`
- Los `trait`de Scala son similares a las `interface` de Java.

- Los `trait` no pueden instanciarse
- Los métodos definidos en una clase tienen precedencia sobre los de un `trait`
- Los `trait` no tienen estado propio, sino el del objeto o la instancia de la clase a la que se aplica

---

#### Ejemplo 2: Un iterador con Scala traits

```scala hl_lines="4"
trait Iterator[A] {
  def hasNext: Boolean
  def next(): A
}

class IntIterator(to: Int) extends Iterator[Int] {
  private var current = 0
  override def hasNext: Boolean = current < to
  override def next(): Int =  {
    if (hasNext) {
      val t = current
      current += 1
      t
    } else 0
  }
}

val iterator = new IntIterator(10)
println(iterator.next())  // prints 0
println(iterator.next())  // prints 1
```

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Un `trait` de Scala es un _mixin_?

---

### Ejemplo: mezcla de traits con comportamiento

```scala
trait Fighter {
    def fight(): String   //abstract
}

trait Flyer {
    def startFlying(): Unit = println("start flying")
    def stopFlying(): Unit = println("stop flying")
}

trait Swimmer {
    def startSwimming(): Unit = println("start swimming")
    def stopSwimming(): Unit = println("stop swimming")
}

class Hero(name: String) extends Fighter with Flyer {
    def fight(): String = "thump!"
}

class AmphibiousHero extends Fighter with Flyer with Swimmer {
    def fight(): String = "splash!"
}
```

---

```scala
object Test {
  def main(args: Array[String]): Unit = {
    val superman = new Hero("Superman")
    val aquawoman = new AmphibiousHero  

    println( superman.fight() )
    superman.startFlying()
    println( aquawoman.fight() )
    aquawoman.startSwimming()

    val aquaman = new Hero("Aquaman") with Swimmer
    aquaman.startSwimming()
  }
}
```

---

### Scala traits como mixins

Los traits de Scala tienen una interfaz que las clases heredan (`extends`)

Entonces... una clase que extiende un trait con un comportamiento, ¿va contra el principio general de que la [herencia de comportamiento](https://en.wikipedia.org/wiki/Composition_over_inheritance#Benefits) es una mala idea?

- Odersky llama __mixin traits__ a los traits con comportamiento
- Para ser un mixin genuino, un trait debería mezclar comportamiento y no interfaces heredadas

Lectura recomendada: [Scala Mixins: The right way](http://baddotrobot.com/blog/2014/09/22/scala-mixins/)

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Y en Java no hay _traits_?

---

### Java default methods

- Desde Java 8, las interfaces pueden incorporar [métodos por defecto](https://www.baeldung.com/java-static-default-methods) que hacen que las interfaces de Java se comporten más como un trait.
- Sirven para implementar herencia múltiple

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

¿Qué ventajas tienen las implementaciones basadas en __Composición__ frente a las basadas en __Herencia__ (estática)?

---

<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: black;
}
</style>

La respuesta está en la **inyección de dependencias**...
