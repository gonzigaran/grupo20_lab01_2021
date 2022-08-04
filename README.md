# *Lab1:* Programación Funcional

> Paradigmas de la Programación
> 
> 2021

## Resumen

El trabajo propuesto por la cátedra consistió en implementar un pequeño ***DSL*** *(Domain Specific Language)* en **Haskell** que nos permitiese resolver un problema concreto: combinar dibujos básicos para crear diseños más complejos. La idea original es la que se encuentra en el artículo ***Functional Geometry*** de *Peter Henderson*.

Nuestra tarea, en particular, consistió en definir, en primer lugar, la *sintaxis* a utilizar, para luego pasar a la *semántica* (conceptos trabajados en la parte teórica de la materia) y, finalmente, crear un pequeño programa que, haciendo uso de las implementaciones hechas, genere una figura de Escher. 

## Decisiones y complicaciones

Si bien durante el proyecto fuimos tratando de implementar las funcionalidades de la manera que nos explicitaban en la consigna y en los comentarios de los archivos (recurriendo al articulo de *Peter Henderson* para algunas interpretaciones puntiales), y nuestro tabajo se basó mayormente en tratar de entender aquello que ya estaba escrito, tomamos algunas decisiones que nos parece importante resaltar.

En primer lugar, modificamos levemente la función *`Interp.grid`*, que originalmente era:

```haskell
grid n v sep l = pictures [ls,translate 0 (l*toEnum n) (rotate 90 ls)]
    where ls = pictures $ take (n+1) $ hlines v sep l
```
y finalmente nos quedó:

```haskell    
grid n v l sep = pictures [ls, rotate 90 ls]
    where ls = pictures $ take (n+1) $ hlines v l sep
```
La decisión fue en base a que, por un lado, las variables `l` y `sep` estaban usadas al revés en la función *`hlines`*, y por otro lado, porque al querer cambiar las dimensiones de la grilla nos daba complicaciones (las líneas verticales de la grilla no se graficaban). Encontramos que modificar la función de la forma propuesta, este problema desaparecía. 

En segundo lugar en el módulo de `Main.hs`, ampliamos el tipo de dato de la configuración `Conf a` para agregarle un nombre a la ventana del gráfico, y luego generamos 2 configuraciones distintas, una para el ejemplo y otra para escher, pudiendo alternar entre una y otra para ejecutar el programa. 

Por último, para `Escher.hs` tomamos la decisión de elegir el tipo de dato `Escher` de la siguiente manera:

```haskell
    data Escher = Blanco | Fig
```

Aunque utilizamos esos 2 constructures, notamos que era importante contar con un tipo de datos que tenga 2 opciones, una para la figura vacía, y otra para la figura que ibamos a usar para repetir. 

## Preguntas planteadas por la cátedra

1. *¿Por qué están separadas las funcionalidades en los módulos indicados?*

Las funcionalidades están separadas en los siguientes módulos:

 - `Dibujo.hs` : se define el tipo de datos `Dibujo` y las funciones que se asocian a este tipo de dato
 - `Interp.hs` : se le da la interpretación geométrica a los dibujos y se definen algunas figuras básicas
 - `Main.hs` : en este módulo se define el programa y se configuran los parámetros a utilizar
 - `Basica/` : en esta carpeta añadimos los módulos en los que vamos crear  figuras más complejas a partir de todo lo definido anteriormente. En este caso, `Escher.hs` 

El objetivo de tener modulzarizado el código como está descrito arriba, es para facilitar, entre otras cosas, su manipulación, sus futuros cambios. Así, si, por ejemplo, se quiere formar una figura diferente a la de *Escher* (con las figuras básicas ya existentes), solo habría que modificar uno de los módulos. De igual manera, si queremos modificar la sintaxis del *DSL* nos deberíamos centrar en el módulo `Dibujo.hs`, y si estamos interesados en la semántica, trabajaríamos con `Interp.hs`. De esta manera, por supuesto que no solo tenemos facilidad a la hora de realizar cambios, sino también para comprender el funcionamiento del *DSL*.

2. *¿Harían alguna modificación a la partición en módulos dada?*

Observamos que en el módulo de `Interp.hs` se ubican, primero una serie de figuras básicas (como `trian1`, `trianD`, `fShape`, etc) y después la interpretación de los constructores para terminar generando los `FloatingPic` a graficar. Pensamos que acá se podría separar en 2 módulos distintos, generando un módulo con figuras básicas, y dejando en `Interp.hs` las distintas funciones para interpretar cada constructor y la función final `interp`.

3. *¿Por qué las imágenes básicas no están incluidas en la definición del lenguaje, y en vez es un parámetro del tipo?*

Al implementar las imágines básicas por fuera de la definición del lenguaje, nos permite tener flexibilidad a la hora de trabajar. Así, podríamos no solo agregar nuevas figuras básicas sin tener que modificar el módulo `Dibujo.hs` (cuadrados, círculos, etc.), sino que también nos permite trabajar con distintos tipos de datos. De esta manera, podemos aplicar nuestro lenguaje a TAD's diferentes. En particular, la manera que tuvimos de testear lo que íbamos definiendo en el módulo `Dibujo.hs` fue aplicar los constructores y funciones implementadas a enteros o booleanos.

4. *¿Cómo hace `Interp.grid` para contruir la grilla?*

 En primer lugar, la función *`Interp.grid`* toma un **entero** (*n*), un **vector** (*v*), dos **float** (*l* y *s*) y devuelve un **picture** que va a ser la grilla. Ahora, podemos pensar la función en dos partes. 

```haskell
    grid :: Int -> Vector -> Float -> Float -> Picture
    grid n v l s = pictures [ls, rotate 90 ls]
```

 En la primer línea utiliza el constructor **pictures** para efectuar la *unión* entre una *Picture* y ella misma rotada 90º (esto último se hace con el constructor *rotate* con argumentos *90* y *ls*). Aun hace falta entender qué representa *ls*, pero spolier, van a ser línes paralelas que, superpuestas con ellas mismas pero rotadas 90º, forman una grilla.

```haskell
    where ls = pictures $ take (n+1) $ hlines v l s]
```

En esta segunda línea de la función se puede observar que *ls* se define a partir del constructor **pictures** que toma como argumento una lista con las primeras *n+1* líneas paralelas de largo *l* y con separación *s* creadas con la función *hlines*.

## Punto Estrella: Fibonacci

Para el punto estrella decidí realizar el gráfico de [Fibonacci](https://es.wikipedia.org/wiki/Sucesi%C3%B3n_de_Fibonacci). Para el cual necesito primero crear una figura básica, que sea una linea entre las dos esquinas opuestas, y luego, en `Basica/Fibonacci.hs` realizar la función iterativa que va ubicando la figura básica en los distintos lugares para formar una aproximación al siguiente gráfico:

![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Fibonacci_spiral_34.svg/1920px-Fibonacci_spiral_34.svg.png) 

Primero realizamos la figura básica `diag` que es una linea diagonal entre las 2 esquinas opuestas y le agregamos el recuadro que nos va a servir para visualizar en el gráfico de Fibonacci: 

![](https://i.imgur.com/TH7W5fD.png)

Para la función que crea la figura de Fibonacci, vamos a utilizar una función complementaria que nos va a ir calculando la sucesión de fibonacci para el número de iteraciónes. Esta sucesión la vamos a usar a la hora de Apilar, ya que vamos a usar F_n y F_n-1 como los valores de los anchos de las 2 figuras a pegar, y así ir aproximando a la proporción aurea (con el objetivo que cada recuadro se parezca lo más posible a un cuadrado)

Con esta figura básica, obtenemos el siguiente gráfico de fibonacci para 30 iteraciones:
![](https://i.imgur.com/8bOsMuS.png)

Una vez con la función funcionando, vamos buscar generar un arco en la diagonal para imitar la figura de Fibonacci. Creando el arco y ajustandolo para que sea invariante a las diferentes transformaciones (rotaciones, apilar, etc), obtenemos lo siguiente:

![](https://i.imgur.com/Vo7Z8iW.png)