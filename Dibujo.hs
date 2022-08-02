module Dibujo where

-- Definir el lenguaje.

data Dibujo a = Basica a | Rotar (Dibujo a) | Espejar (Dibujo a) | Rot45 (Dibujo a)
                | Apilar Int Int (Dibujo a) (Dibujo a)
                | Juntar Int Int (Dibujo a) (Dibujo a)
                | Encimar (Dibujo a) (Dibujo a)
                deriving (Show)

-- Composición n-veces de una función con sí misma.
-- Componer 0 veces una función es la identidad, es decir, devuelve
-- el parámetro sin aplicarlo a la función.
comp :: (a -> a) -> Int -> a -> a
comp f 0 x = x
comp f n x = comp f (n-1) (f x)

-- Rotaciones de múltiplos de 90.
r180 :: Dibujo a -> Dibujo a
r180 = comp Rotar 2

r270 :: Dibujo a -> Dibujo a
r270 = comp Rotar 3

-- Pone una figura sobre la otra, ambas ocupan el mismo espacio.
(.-.) :: Dibujo a -> Dibujo a -> Dibujo a
x .-. y = Apilar 1 1 x y

-- Pone una figura al lado de la otra, ambas ocupan el mismo espacio.
(///) :: Dibujo a -> Dibujo a -> Dibujo a
x /// y = Juntar 1 1 x y

-- Superpone una figura con otra.
(^^^) :: Dibujo a -> Dibujo a -> Dibujo a
x ^^^ y = Encimar x y

-- Dadas cuatro figuras las ubica en los cuatro cuadrantes.
cuarteto :: Dibujo a -> Dibujo a -> Dibujo a -> Dibujo a -> Dibujo a
cuarteto w x y z = (w /// x) .-. (y /// z)

-- Una figura repetida con las cuatro rotaciones, superpuestas.
encimar4 :: Dibujo a -> Dibujo a 
encimar4 x = x ^^^ Rotar x ^^^ r180 x ^^^ r270 x

-- Cuadrado con la misma figura rotada i * 90, para i ∈ {0, ..., 3}.
-- No confundir con encimar4!
ciclar :: Dibujo a -> Dibujo a
ciclar x = cuarteto x (Rotar x) (r180 x) (r270 x)

-- Ver un a como una figura.
pureDib :: a -> Dibujo a
pureDib = Basica

-- map para nuestro lenguaje.
mapDib :: (a -> b) -> Dibujo a -> Dibujo b
mapDib f (Basica x) = Basica (f x)
mapDib f (Rotar d) = Rotar (mapDib f d)
mapDib f (Espejar d) = Espejar (mapDib f d)
mapDib f (Rot45 d) = Rot45 (mapDib f d)
mapDib f (Apilar n m d s) = Apilar n m (mapDib f d) (mapDib f s)
mapDib f (Juntar n m d s) = Juntar n m (mapDib f d) (mapDib f s)
mapDib f (Encimar d s) = Encimar (mapDib f d) (mapDib f s)

-- Estructura general para la semántica (a no asustarse). Ayuda: 
-- pensar en foldr y las definiciones de intro a la lógica
sem :: (a -> b) -> (b -> b) -> (b -> b) -> (b -> b) ->
       (Int -> Int -> b -> b -> b) -> 
       (Int -> Int -> b -> b -> b) -> 
       (b -> b -> b) ->
       Dibujo a -> b
sem bas rot esp rot45 api jun enc (Basica x) = bas x
sem bas rot esp rot45 api jun enc (Rotar d) = rot (sem bas rot esp rot45 api jun enc d)
sem bas rot esp rot45 api jun enc (Espejar d) = esp (sem bas rot esp rot45 api jun enc d)
sem bas rot esp rot45 api jun enc (Rot45 d) = rot45 (sem bas rot esp rot45 api jun enc d)
sem bas rot esp rot45 api jun enc (Apilar n m d s) = api n m (sem bas rot esp rot45 api jun enc d) (sem bas rot esp rot45 api jun enc s)
sem bas rot esp rot45 api jun enc (Juntar n m d s) = jun n m (sem bas rot esp rot45 api jun enc d) (sem bas rot esp rot45 api jun enc s)
sem bas rot esp rot45 api jun enc (Encimar d s) = enc (sem bas rot esp rot45 api jun enc d) (sem bas rot esp rot45 api jun enc s)

type Pred a = a -> Bool 

-- Dado un predicado sobre básicas, cambiar todas las que satisfacen
-- el predicado por la figura básica indicada por el segundo argumento.
cambiar :: Pred a -> a -> Dibujo a -> Dibujo a
cambiar pred x = mapDib f 
                where 
                    f y | pred y = x
                        | otherwise = y

-- Alguna básica satisface el predicado.
anyDib :: Pred a -> Dibujo a -> Bool
anyDib pred dib = any pred (basicas dib)

-- Todas las básicas satisfacen el predicado.
allDib :: Pred a -> Dibujo a -> Bool
allDib pred dib = all pred (basicas dib)

-- Los dos predicados se cumplen para el elemento recibido.
andP :: Pred a -> Pred a -> Pred a
andP pred1 pred2 dib = pred1 dib && pred2 dib

-- Algún predicado se cumple para el elemento recibido.
orP :: Pred a -> Pred a -> Pred a
orP pred1 pred2 dib = pred1 dib || pred2 dib

-- Describe la figura. Ejemplos: 
--   desc (const "b") (Basica b) = "b"
--   desc (const "b") (Rotar (Basica b)) = "rot (b)"
--   desc (const "b") (Apilar n m (Basica b) (Basica b)) = "api n m (b) (b)"
-- La descripción de cada constructor son sus tres primeros
-- símbolos en minúscula, excepto `Rot45` al que se le agrega el `45`.
-- desc :: (a -> String) -> Dibujo a -> String
-- desc f (Basica fig) = f fig
-- desc f (Rotar dib) = "rot (" ++ desc f dib ++ ")"
-- desc f (Espejar dib) = "esp (" ++ desc f dib ++ ")"
-- desc f (Rot45 dib) = "rot45 (" ++ desc f dib ++ ")"
-- desc f (Apilar x y dib1 dib2) = "api " ++ show x ++ " " ++ show y ++ " (" ++ desc f dib1 ++ ") (" ++ desc f dib2 ++ ")"
-- desc f (Juntar x y dib1 dib2) = "jun " ++ show x ++ " " ++ show y ++ " (" ++ desc f dib1 ++ ") (" ++ desc f dib2 ++ ")"  
-- desc f (Encimar dib1 dib2) = "enc (" ++ desc f dib1 ++ ") (" ++ desc f dib2 ++ ")" 
desc :: (a -> String) -> Dibujo a -> String
desc f = sem f (desc1 "rot") (desc1 "esp") (desc1 "rot45") (desc2_2 "api") (desc2_2 "jun") (desc2 "enc")
        where 
            desc1 s dib = s ++ " (" ++ dib ++ ")"
            desc2_2 s x y dib1 dib2 = s ++ " " ++ show x ++ " " ++ show y ++ " (" ++ dib1 ++ ") (" ++ dib2 ++ ")"
            desc2 s dib1 dib2 = s ++ " (" ++ dib1 ++ ") (" ++ dib2 ++ ")"

-- Junta todas las figuras básicas de un dibujo.
-- basicas :: Dibujo a -> [a]
-- basicas (Basica fig) = [fig]
-- basicas (Rotar dib) = basicas dib
-- basicas (Espejar dib) = basicas dib
-- basicas (Rot45 dib) = basicas dib
-- basicas (Apilar x y dib1 dib2) = basicas dib1 ++ basicas dib2
-- basicas (Juntar x y dib1 dib2) = basicas dib1 ++ basicas dib2
-- basicas (Encimar dib1 dib2) = basicas dib1 ++ basicas dib2
basicas :: Dibujo a -> [a]
basicas = sem bas id id id app2 app2 (++)
        where 
            bas fig = [fig]
            app2 _ _ dib1 dib2 = dib1 ++ dib2

-- Hay 4 rotaciones seguidas.
esRot360 :: Pred (Dibujo a)
esRot360 (Basica x) = False
esRot360 (Rotar (Rotar (Rotar (Rotar x)))) = True
esRot360 (Rotar x) = esRot360 x
esRot360 (Espejar x) = esRot360 x
esRot360 (Rot45 x) = esRot360 x
esRot360 (Apilar n m x y) = esRot360 x && esRot360 y
esRot360 (Juntar n m x y) = esRot360 x && esRot360 y
esRot360 (Encimar x y) = esRot360 x && esRot360 y

-- Hay 2 espejados seguidos.
esFlip2 :: Pred (Dibujo a)
esFlip2 (Basica x) = False
esFlip2 (Espejar (Espejar x)) = True
esFlip2 (Espejar x) = esFlip2 x
esFlip2 (Rotar x) = esFlip2 x  
esFlip2 (Rot45 x) = esFlip2 x
esFlip2 (Apilar n m x y) = esFlip2 x && esFlip2 y
esFlip2 (Juntar n m x y) = esFlip2 x && esFlip2 y
esFlip2 (Encimar x y) = esFlip2 x && esFlip2 y

data Superfluo = RotacionSuperflua | FlipSuperfluo
                deriving (Show)

-- Aplica todos los chequeos y acumula todos los errores, y
-- sólo devuelve la figura si no hubo ningún error.
check :: Dibujo a -> Either [Superfluo] (Dibujo a)
check dib | not (esRot360 dib) && not (esFlip2 dib) = Right dib
          | not (esRot360 dib) && esFlip2 dib = Left [FlipSuperfluo]
          | esRot360 dib && not (esFlip2 dib) = Left [RotacionSuperflua]
          | otherwise = Left [RotacionSuperflua, FlipSuperfluo]