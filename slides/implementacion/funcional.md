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

# PROGRAMACIÓN FUNCIONAL

---

<!-- paginate: true -->

<style scoped>
p {
  text-align: center;
}
</style>

## INTERFACES FUNCIONALES

---

### Caso práctico: Comparación de personas

Deseamos ordenar por criterios distintos cada vez (id, fecha, etc.)

- Alternativa 1: definir subclases `PersonaPorNombre`, `PersonaPorFechaNacimiento`...
  - Mucho código repetido (no cumple DRY)
  - Muchos cambios si se añade un nuevo criterio (no cumple OCP)

- Alternativa 2: No usar herencia, sino composición/delegación
  - Factorizar la _función_ de comparación
  - No delegar hacia las subclases
  - Delegar en objeto de otra clase que implemente la interfaz `java.util.Comparator`

---

Usando composición/delegación:

```java
class OrdenarPersonaPorId implements java.util.Comparator<Persona> {
    public int compare(Persona o1, Persona o2) {
        return o1.getIdPersona() - o2.getIdPersona();
    }
}

Collections.sort(personas, new OrdenarPersonaPorId());
```

La __función factorizada__ (la implementación de `Comparator`) es sustituible en tiempo de ejecución mediante inyección de dependencias

---

### Clases anónimas

#### Ejemplo: versión con clases anónimas

```java
Collections.sort(personas, 
  new java.util.Comparator<Persona>() {
    public int compare(Persona o1, Persona o2) {
      return o1.getIdPersona() - o2.getIdPersona();
    }
  }
);
```

---

__Clases anónimas (Java 7)__

```java
public class ComparatorTest { 
  public static void main(String[] args) {
    List<Person> personList = Person.createShortList();

    Collections.sort(personList, new Comparator<Person>(){
      public int compare(Person p1, Person p2){
        return p1.getLastname().compareTo(p2.getLastname());
      }
    });

    System.out.println("=== Sorted Asc Lastname ===");
    for(Person p:personList){
      p.printName();
    }

    Collections.sort(personList, new Comparator<Person>(){
      public int compare(Person p1, Person p2){
        return p2.getLastname().compareTo(p1.getLastname());
      }
    });

    System.out.println("=== Sorted Desc Lastname ===");
    for(Person p:personList){
      p.printName();
    }
  }
}
```

---

__Lambdas (Java 8)__

```java
public class ComparatorTest { 
  public static void main(String[] args) {

    List<Person> personList = Person.createShortList();

    // Print Asc
    System.out.println("=== Sorted Asc Lastname ===");
    Collections.sort(personList, (Person p1, Person p2) ->
      p1.getLastname().compareTo(p2.getLastname()));

    for(Person p:personList){
      p.printName();
    }

    // Print Desc
    System.out.println("=== Sorted Desc Lastname ===");
    Collections.sort(personList, (p1,  p2) ->
      p2.getLastname().compareTo(p1.getLastname()));

    for(Person p:personList){
      p.printName();
    }
  }
}
```

---

### Clases locales o internas

- Son clases locales (_inner classes_) declaradas sin nombre, dentro de métodos
- Pueden hacer referencia a identificadores declarados en la clase y a variables de solo lectura (`final`) del método en que se declaran
- Sirven para clases que solo aparecen una vez en la aplicación

---

```java
public class EnclosingClass {
  public class InnerClass {
    public int incrementAndReturnCounter() {
      return counter++;
    }
  }

  private int counter;
  {
    counter = 0;
  }

  public int getCounter() {
    return counter;
  }

  public static void main(String[] args) {
    EnclosingClass enclosingClassInstance = new EnclosingClass();
    EnclosingClass.InnerClass innerClassInstance =
      enclosingClassInstance.new InnerClass();
    for( int i = enclosingClassInstance.getCounter();
         (i = innerClassInstance.incrementAndReturnCounter()) < 10; ) {
      System.out.println(i);
    }
  }
}
```

---

### Predicados

En Java 8, inspirado por la biblioteca _guava_, se incluyen predicados como una forma de interfaz funcional.

En la biblioteca Guava, los [`Iterators`](https://google.github.io/guava/releases/15.0/api/docs/com/google/common/collect/Iterators.html) tienen un método [`filter`](https://google.github.io/guava/releases/15.0/api/docs/com/google/common/collect/Iterators.html#filter) que recibe un objeto de tipo [`Predicate`](https://google.github.io/guava/releases/15.0/api/docs/com/google/common/base/Predicate.html).

Desde Java 8 existe una clase similar [`Predicate`](https://docs.oracle.com/javase/8/docs/api/java/util/function/Predicate.html).

---

### Ejemplo: partidos de una competición

__Con clases anónimas:__

```java
final Predicate<Match> condition = new Predicate<Match>() {
  final Team team1 = new Team("Cadiz CF");
  final Team team2 = new Team("RC Betis");
  public boolean apply(Match match) {
    return match.getLocalTeam().equals(team1) &&
           match.getVisitingTeam().equals(team2);
  }
};
Iterator matchesByTeam = Iterators.filter(matches, condition);
for (matches: matchesByTeam) { ... };
```

---

__Sin clases anónimas:__

```java
class FilterByTeam implements Predicate<Match> {
  Team localTeam, visitingTeam;

  public FilterByTeam(Team t1, Team t2) {
      this.localTeam = t1;
      this.visitingTeam = t2;
  }

  public boolean apply(Match match) {
      return match.getLocalTeam().equals(t1) || 
             match.getVisitingTeam().equals(t2);
  }
}
```

---

__Guava y Java 8__

Guava emplea `FluentIterable` para poder encadenar varios `Iterable` sin que haya problemas con el retorno de null en la programación _fluent_. La biblioteca estándar de Java 8 sustituye la solución del `FluentIterable` por los `Predicate` o por el uso de `StreamSupport` para resolver dicho problema.

Lectura recomendada: [From Guava's FluentIterable via StreamSupport to Java 8 Streams](https://verhoevenv.github.io/2015/08/18/fluentiterable-streamsupport-java8.html)

---

Comprobar que, en un cierto grupo de la competición, un mismo partido no está repetido ni se enfrenta un equipo contra sí mismo:

```java
private void checkMatchesInGroup(List<Match> matchesInGroup) {
  for (Match match: matchesInGroup) {
      Team t1 = match.getLocalTeam();
      Team t2 = match.getVisitingTeam();
      assertNotSame(t1, t2);
      List<Match> firstLeg =
          FluentIterable.from(matchesInGroup)
                        .filter(new FilterByTeam(t1, t2))
                        .toImmutableList();
      assertTrue(firstLeg.size()==1);
      List<Match> secondLeg =
          FluentIterable.from(matchesInGroup)
                        .filter(new FilterByTeam(t2, t1))
                        .toImmutableList();
      assertTrue(secondLeg.size()==0);
  }
}
```

<!--

---

### Retrollamadas (_callbacks_)

- Un __callback__ o retrollamada es un fragmento de código ejecutable que se pasa como argumento.
- Hacen falta interfaces funcionales para poder definir retrollamadas

---

#### Implementaciones en C/C++

- Puntero a función:
    ```c
      int (*f)(void)
    ```
- Con puntero asociado a datos:
    ```c
      void (*f)(void *data)
    ```
- _functor_ en C++
    - clase que define `operator()`
    - es una clase y por tanto pueden contener un estado

-->

---

<!-- paginate: true -->

<style scoped>
p {
  text-align: center;
}
</style>

## LAMBDAS

---

### Funciónes anónimas o *lambdas*

- Función o subrutina definida y (posiblemente) llamada sin necesidad de asociarla a un identificador o nombre
- Se suelen pasar como argumento a funciones de orden superior
- Son funciones anidadas que permiten acceder a variables definidas en el ámbito de la contenedora (variables no locales a la función anónima)
- Muchos lenguajes las introducen a través de la palabra reservada `lambda`

---

### Expresión lambda

Una expresión *lambda* es una función anónima (con o sin parámetros) que es llamada sin necesidad de asociarle un nombre explícito.

Sirven para pasarlas como argumento a funciones de orden superior, momento en el cual los parámetros de la función anónima toman un valor en el contexto de ejecución de la función contenedora que la recibe y ejecuta.

Por tanto, las funciones anónimas permiten acceder a variables (no locales) definidas en el ámbito de la contenedora.

---

### Lambdas en los lenguajes

Mecanismos de los lenguajes para implementar funciones anónimas:

- En C++: funciones anónimas, objetos función (_functors_) o [funciones lambda](http://en.cppreference.com/w/cpp/language/lambda) (desde C++11)
- En Java 8: [expresiones lambda](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/Lambda-QuickStart/index.html)
- En Ruby: [blocks, procs y lambdas](https://www.blackbytes.info/2016/02/ruby-procs-and-lambdas/)
- En C\#: [delegates](https://msdn.microsoft.com/en-us/library/ms173171.aspx) (métodos anónimos y expresiones lambda)
- En Python: [generators, comprehensions, lambda expressions](https://docs.python.org/2/howto/functional.html)

---

#### Lambdas en Java

__Sintaxis__

```java
  ( argumentos ) -> expresión
```

__Ejemplos__

```java
  (int x, int y) -> x + y
  () -> 42
  (String s) -> { System.out.println(s); }
```

---

#### Lambdas en Ruby

__Blocks__

```ruby 
  { | argumentos | expresión }
```

__Lambdas__

```ruby
  ->(argumentos) { expresión }
```

__Ejemplos__

```ruby
  [1, 2, 3].each { |num| puts num * 2 }
  # 2 4 6

  times_two = ->(x) { x * 2 }
  times_two.call(10)
  # 20
```

---

#### Lambdas en C++

__Sintaxis__

```c++
[capture](parameters) -> return_type { body }
```

__*capture* = entorno de referencia__

`[]`       – Sin variables externas definidas. Erróneo intentar utilizar cualquier variable externa
`[x, &y]`  – `x` se captura por copia, `y` por referencia
`[&]`      – Toda variable externa utilizada es capturada implícitamente por referencia
`[=]`      – Toda variable externa utilizada es capturadas implícitamente por copia
`[&, x]`   – `x` se captura explícitamente por copia; el resto, por referencia
`[=, &z]`  – `z` se captura explícitamente por referencia; el resto, por copia

---

### Clausuras o _closures_

- __Clausura__ = función o referencia a función junto con un _entorno de referencia_

  - La diferencia entre una función normal y una clausura es que una clausura depende de una o varias __variables libres__.
  - Una clausura permite acceder a las variables libres fuera de su ámbito léxico (i.e. alcance), incluso cuando se invoca desde fuera de ese ámbito.

---

#### Entorno de referencia de una clausura

- Tabla que guarda una referencia a cada una de las variables no locales (_libres_) de la función

  - __Variable libre__ (_free_): notación lógica matemática que especifica los lugares de una expresión donde tiene lugar una sustitución
  - __Variable asignada__ (_bound_): variable que era libre previamente pero a la que le ha sido asignado un valor o conjunto de valores

---

#### Anónimas y clausuras en C++ 

```cpp
std::vector<int> some_list; // assume that contains something
int total = 0;
for (int i=0;i<5;++i) some_list.push_back(i);
std::for_each(
  begin(some_list),
  end(some_list),
  [&total](int x) { total += x; }
);
// Computes the total of all elements in the list.
/* Variable total is stored as a part of the lambda function's closure.
   Since it is a reference to the stack variable total, it can change
   its value. */
```

---

- Una _clausura_ en C++ se expresa mediante la parte [_capture_]
- El _entorno de referencia_ se expresa por el conjunto de variables externas indicadas dentro de la clausura
- Las variables del entorno de referencia en C++ pueden ser capturadas por copia (`[=]`) o por referencia (`[&]`)
- Mutabilidad de variables en _body_
  - Las variables externas capturadas son inmutables por defecto
  - `mutable` después de los (_parameters_): permite que _body_ modifique los objetos capturados por copia

---

__Lecturas recomendadas: Lambdas en C++__

- [Lambda Functions in C++11 - the Definitive Guide](https://www.cprogramming.com/c++11/c++11-lambda-closures.html)
- La historia de las lambdas en C++: [Parte 1](https://www.bfilipek.com/2019/02/lambdas-story-part1.html) y [Parte 2](https://www.bfilipek.com/2019/03/lambdas-story-part2.html)

__Tutoriales recomendado:__

- [Mejorando código con expresiones lambda](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/Lambda-QuickStart/index.html\#section3)
- [Closures en Scala](https://madusudanan.com/blog/scala-tutorials-part-30-closures/)

---

#### Anónimas y clausuras en Java

##### Captura de variables en lambdas

Una expresión lambda en Java puede **capturar** (o no)...

- variables de instancia no locales (atributos de la clase contenedora) y
- variables locales (declaradas o no `final`, pero cuyo valor no es modificado)

...del ámbito contenedor.

<!--

---

__Ejemplo: Lambda que captura variables locales `final`__

```java
final BigDecimal bd = new BigDecimal(1);
final BigDecimal x = new BigDecimal(2);
Function<BigDecimal, BigDecimal> func =
    (a) -> bd.multiply(a).add(x);

for (int j = 0; j < 999999999; j++) {
    func.apply(new BigDecimal(j));
}
```

---

__Ejemplo: Lambda que captura variables locales no declaradas `final` pero cuyo valor no es modificado__

```java
BigDecimal bd = new BigDecimal(1);
BigDecimal x = new BigDecimal(2);
 // Se puede consultar x pero no se podría cambiar el valor de x:
Function<BigDecimal, BigDecimal> func =
    (a) -> bd.multiply(a).add(x);
    // x debe ser final o efectivamente final:
    // (a) -> { bd.multiply(a).add(x); x = new BigDecimal(0); return bd; };

for (int j = 0; j < 999999999; j++) {
    func.apply(new BigDecimal(j));
}
```

---

__Ejemplo: Lambda que captura variables de instancia de la clase contenedora__

```java
public class LambdaInstanceCapturing implements Runnable {
    private BigDecimal bd = new BigDecimal(1);

    @Override
    public void run() {
        Function<BigDecimal, BigDecimal> func =
            (a) -> bd.multiply(a);

        for (int j = 0; j < 999999999; j++) {
            func.apply(new BigDecimal(j));
        }
    }
}
```

-->

---

##### Lambdas y clases anónimas internas

En Java, una expresión lambda y una clase anónima interna (_inner class_) tienen un propósito similar, pero son diferentes en un aspecto: el **ámbito** (_scope_) de la definición de las variables locales.

- Cuando se usa una inner class, se crea un __nuevo ámbito__ para dicha clase.
  - Se pueden ocultar las variables locales para el ámbito contenedor instanciando nuevas variables con el mismo nombre.
  - También se puede usar la palabra reservada `this` dentro de una clase anónima para hacer referencia a su instancia.

- Sin embargo, las expresiones lambda trabajan con el __ámbito contenedor__.
  - No se pueden ocultar las variables del ámbito contenedor dentro del cuerpo de la expresión lambda.
  - `this` hace referencia a una instancia de la clase contenedora.

---

En el ejemplo siguiente, ¿qué valor devuelve `scopeExperiment()`?:

```java
@FunctionalInterface
public interface ClaseFuncional{
  String method(String string);
}

private String variable = "Valor de la contenedora";

//...

public String scopeExperiment() {

  ClaseFuncional unaInnerClass = new ClaseFuncional() {
      String variable = "Valor de la inner class";
      @Override
      public String method(String string) {
          return this.variable;
            /*  Con o sin this, no hay lambdas ni variables libres */
      }
  };
  String resultadoInnerClass = unaInnerClass.method("");

  ClaseFuncional unaLambda = parametro -> {
      String variable= "Valor de la lambda";
      return this.variable; 
        /* Con this, la clausura de la variable libre se produce
           con el valor de ClaseFuncional::variable */
  };
  String resultadoLambda = unaLambda.method("");

  return "resultadoInnerClass = " + resultadoInnerClass +
    ",\nresultadoLambda = " + resultadoLambda;
}
```

---

El valor será:

```text
resultadoInnerClass  = Valor de la inner class,
resultadoLambda = Valor de la contenedora
```

---

#### Funciones anónimas en Ruby

##### Bloques (_blocks_)

__Sintaxis `do` ... `end`__

  ```ruby
  some_list = [ 10, 20, 30 ]
  some_list.map do |i|
      i += 1
  end
  ```

__Sintaxis `{` ... `}`__

  ```ruby
  some_list = [ 10, 20, 30 ]
  some_list.map { |i| i += 1 }
  ```

El método `map` itera y aplica un bloque repetitivamente a cada elemento de una colección (representado por el parámetro `i`)

---

##### Ejemplo: búsqueda en una lista

__Sin bloques:__


  ```ruby
  class SongList
    def with_title(title)
      for i in 0...@songs.length
        return @songs[i] if title == @songs[i].name
      end
      return nil
    end
  end
  ```

__Con bloques (sintaxis `do` ... `end`):__

  ```ruby
  class SongList
    def with_title(title)
      @songs.find do |song|
        title == song.name
      end
    end
  end
  ```

---

__Con bloques (sintaxis `{` ... `}`):__

  ```ruby
  class SongList
    def with_title(title)
      @songs.find { |song| title == song.name }
    end
  end
  ```

El método `find` itera y aplica el test del bloque a cada elemento `song` de la colección.

---

##### Ejecución de bloques

- El bloque debe aparecer al lado de una llamada a método
- No se ejecuta el bloque, sino que se recuerda el contexto (variables locales, objeto actual, etc.) en que aparece
- Cuando se ejecuta el método, el bloque es invocado donde aparezca `yield`
- El control vuelve al método después del `yield`
- Al bloque se le pueden pasar parámetros

---

**Ejemplo: fibonacci**

```ruby
def fib_up_to(max)
  i1, i2 = 1, 1
  while i1 <= max
    yield i1
    i1, i2 = i2, i1+i2
  end
end
fib_up_to(1000) {|f| print f, " " }

#Salida => 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987
```

---

**Ejemplo de `yield`:**

```ruby
def three_times
  yield
  yield
  yield
end
three_times { puts "Hello" }
```

---

**Ejemplo: implementación de `Array.find`**

```ruby
class Array
  def find
    for i in 0...size
      value = self[i]
      return value if yield(value)
    end
    return nil
  end
end
```

---

**Ejemplos: iterar con bloques**

- Iterar sobre un array con `each`

  `Array#each`: recibe un array y aplica el bloque a cada item, sin modificar el array ni crear un nuevo objeto; devuelve el mismo array.

  ```ruby
  [ 1, 3, 5, 7, 9 ].each {|i| printf i, " " }
  #Salida => 1 3 5 7 9
  Array a = [ 1, 2, 3, 4 ]
  a.each {|i| puts i*2 }
  #Salida => 2 4 6 8
  #Devuelve => [1, 2, 3, 4]
  a
  #Devuelve => [1, 2, 3, 4]
  ```

---

- Iterar sobre un fichero con `each`

  `File#each`: recibe el contenido de un fichero de texto y aplica el bloque a cada línea.

  ```ruby
  f = File.open("testfile")
  f.each do |line|
    puts line
  end
  f.close
  f = File.open("testfile")
  f.each {|line| puts line}
  f.close
  ```

---

- Iterar sobre un array con `collect`

  `Array#collect`: aplica el bloque a todos los items y devuelve el nuevo array modificado; hace lo mismo que `Array#map`

  ```ruby
  ["H", "A", "L"].collect {|x| x.succ }
  # Salida => [''I'', ''B'', ''M'']
  Array a = [ 1, 2, 3, 4 ]
  a.collect {|i| puts i*2}
  #Salida => 2 4 6 8
  #Devuelve => [nil, nil, nil, nil]
  a.collect {|i| i.succ}
  #Devuelve => [2, 3, 4, 5]
  a
  #Devuelve => [1, 2, 3, 4]
  ```

---

##### Procs y lambdas

- En Ruby, una función anónima o _lambda_ es simplemente un tipo especial de objeto `Proc`
- Definición de procs/lambdas:

  ```ruby
  # sin argumentos:
  say_something = -> { puts "This is a lambda" }
  say_something = lambda { puts "This is a lambda" }
  say_otherwise = Proc.new { puts "This is a proc" }
  # con argumentos:
  times_two = ->(x) { x * 2 }
  ```

---

- Varias formas de llamar a la lambda (es preferible `call`)

  ```ruby
  say_something = -> { puts "This is a lambda" }
  say_something.call
  say_something.()
  say_something[]

  say_otherwise = Proc.new { puts "This is a proc" }
  say_otherwise.call

  times_two = ->(x) { x * 2 }
  times_two.call(10)
  ```

---

- Los `proc` no se preocupan de los argumentos:

  ```ruby
  t = Proc.new { |x,y| puts "I don't care about args!" }
  t.call #Salida: I don't care about args!
  t.call(10) #Salida: I don't care about args!
  t.call(10,10) #Salida: I don't care about args!
  t.call(10,10) #Salida: I don't care about args!

  s = ->(x,y) { puts "I care about args" }
  s.call # ArgumentError: wrong number of arguments (given 0, expected 2)
  s.call(10) # ArgumentError: wrong number of arguments (given 1, expected 2)
  s.call(10,10) # Salida: I care about args
  ```

---

- Los `proc` retornan del método actual; los lambda retornan de la función anónima:

  ```ruby
  # funciona:
  my_lambda = -> { return 1 }
  puts "Lambda result: #{my_lambda.call}"

  # eleva una exceción:
  my_proc = Proc.new { return 1 }
  puts "Proc result: #{my_proc.call}"
  ```

---

- Si el `proc` está dentro de un método, la llamada a `return` es equivalente a retornar de ese método:

  ```ruby
  def call_proc
    puts "Before proc"
    my_proc = Proc.new { return 2 }
    my_proc.call
    puts "After proc"
  end

  puts call_proc
  # Prints "Before proc" but not "After proc"

  def call_lambda
    puts "Before lambda"
    my_lambda = lambda { return 2 }
    my_lambda.call
    puts "After lambda"
  end

  puts call_lambda
  # Prints "Before lambda" and "After lambda"
  ```

---

**Diferencias entre `Proc` y `lambda`:**

- Las lambdas se definen con `-> {}` y los procs con `Proc.new {}`
- Los `Proc` retornan del método actual, las lambdas retornan de la propia función lambda
- Los `Proc` no se preocupan del número correcto de argumentos, las lambdas elevan una excepción

---

##### Paso de bloques como parámetros

- Simplemente, se añade al final de la llamada a un método 
- ¿Dónde se llama al bloque? Donde el método indique con `yield`
- El bloque (realmente un objeto `Proc`) se pasa como una especie de parámetro no declarado

---

**Ejemplos de paso de bloques:**

- Llamada a un bloque sin parámetros

  ```ruby
  def run_it
    puts("Before the yield")
    yield
    puts("After the yield")
  end
  ```

  ```ruby
  run_it do
    puts('Hello')
    puts('Coming to you from inside the block')
  end

  # Salida =>
  #  Before the yield
  #  Hello
  #  Coming to you from inside the block
  #  After the yield
  ```

---

- Cualquier método puede recibir un bloque como parámetro implícito, pero no lo ejecuta si no hace `yield`:

  ```ruby
  def run_it
  end

  run_it do
    puts('Hello')
  end

  # => No genera salida
  ```

---

- Con `yield`:

  ```ruby
  def run_it
    yield if block_given?
  end

  run_it do
    puts('Hello')
  end
  # Salida =>
  #   Hello
  ```

---

- Llamada a un bloque con parámetros:

  ```ruby
  def run_it_with_parameter
    puts('Before the yield')
    yield(24)
    puts('After the yield')
  end

  run_it_with_parameter do |x|
    puts('Hello from inside the proc')
    puts("The value of x is #{x}")
  end

  # Salida =>
  #  Before the yield
  #  Hello from inside the proc
  #  The value of x is 24
  #  After the yield
  ```

---

- Hacer explícito el bloque pasado como parámetro usando _ampersand_: explicitamos que se espera que el método reciba un parámetro de tipo bloque

  ```ruby
  def run_it_with_parameter(&block)
    puts('Before the call')
    block.call(24)
    puts('After the call')
  end
  ```

---

- Convertir un `Proc` o un lambda en un bloque pasado como parámetro:

  ```ruby
  my_proc = Proc.new {|x| puts("The value of x is #{x}")}
  run_it_with_parameter(&my_proc)
  my_lambda = lambda {|x| puts("The value of x is #{x}")}
  run_it_with_parameter(&my_lambda)

  # Salida (en ambos casos) =>
  #  Before the call
  #  The value of x is 24
  #  After the call
  ```

---

__Lecturas recomendadas__

- M. Williams: [Java SE 8: Lambda Quick Start](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/Lambda-QuickStart/index.html), Oracle Learning Library, 2013.
- D. Thomas & A. Hunt: [Programming Ruby. The Pragmatic Programmer's Guide](http://www.ruby-doc.org/docs/ProgrammingRuby/), Addison-Wesley, 2005.

---

## STREAMS

Un stream representa una secuencia de elementos que soportan diferentes tipos de operaciones para realizar cálculos sobre ellos

### Operaciones

Las operaciones sobre un stream pueden ser intermediarias o terminales

- Las operaciones __intermediarias__ devuelven un nuevo stream permitiendo encadenar múltiples operaciones intermediarias sin usar punto y coma
- Las operaciones __terminales__ son nulas o devuelven un resultado de un tipo diferente, normalmente un valor agregado a partir de cómputos anteriores

---

### Ejemplo v0.1

\[Probar en [paiza.io](https://paiza.io/projects/K6lkbmKSYAKnF0o0fo0oEQ?language=java)\]

```java
public class Main{
  public static void main(String []args){
      
    List<String> myList =
      Arrays.asList("a1", "a2", "b1", "c2", "c1");

    myList
      .stream()
      .filter(s -> s.startsWith("c"))
      .map(String::toUpperCase)
      .sorted()
      .forEach(System.out::println);
      
  }
}
```

---

### Streams con interfaces funcionales

- Las operaciones que se aplican sobre un _stream_ aceptan algún parámetro en forma de:

  - __interfaz funcional__: objeto cuyo tipo (clase) representa a una función ejecutable con un cierto número de parámetros (normalmente 0, 1 o 2)
  - __expresión lambda__: interfaz funcional anónima, que especifica el comportamiento de la operación, pero sin especificar formalmente su nombre y tipo de parámetros

- Las operaciones aplicadas no pueden modificar el _estado_ del stream original

---

En el ejemplo anterior, se puede observar que:

- `filter`, `map` y `sorted` son operaciones intermediarias
- `forEach` es una operación terminal
- Ninguna de las operaciones modifica el estado de `myList` añadiendo o eliminando elementos
- Sólo se filtran ciertos elementos, se transforman a mayúsculas, se ordenan (por defecto, alfabéticamente) y se imprimen por pantalla

---

### Ejemplo v0.2

```java
List<String> myList =
  Arrays.asList("a1", "a2", "b1", "c2", "c1");

myList
  .stream()
  .filter(s -> s.startsWith("c"))
  .map(String::toUpperCase)
  .sorted()
  .forEach(System.out::println);

myList
  .stream()
  .reduce( (a,b) -> a + " " + b )
  .ifPresent(System.out::println);
```

---

### Más información

- Winterbe: [Java 8 stream tutorial](https://winterbe.com/posts/2014/07/31/java8-stream-tutorial-examples/)
- Oracle: [Procesamiento de datos con streams de Java](https://www.oracle.com/lad/technical-resources/articles/java/processing-streams-java-se8.html) 
- Oracle: [Introducción a Expresiones Lambda y API Stream en Java](https://www.oracle.com/lad/technical-resources/articles/java/expresiones-lambda-api-stream-java-part2.html)

