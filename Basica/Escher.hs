module Basica.Escher where
import Dibujo
import Interp
import Graphics.Gloss.Data.Picture ( Picture( Blank ) )

-- Supongamos que eligen.

data Escher = Blanco | Fig

f2 = Rot45 
f3 = r270 . f2

-- El dibujoU.
dibujoU :: Dibujo Escher -> Dibujo Escher
dibujoU p = (^^^) (f2 p ^^^ Rotar (f2 p))
                  (r180 (f2 p) ^^^ r270 (f2 p))

-- El dibujo t.
dibujoT :: Dibujo Escher -> Dibujo Escher
dibujoT p = p ^^^ (f2 p ^^^  f3 p )

-- Esquina con nivel de detalle en base a la figura p.
esquina :: Int -> Dibujo Escher -> Dibujo Escher
esquina 0 p = pureDib Blanco
esquina n p = cuarteto (esquina (n-1) p) (lado (n-1) p) (Rotar (lado (n-1) p)) (dibujoU p)

-- Lado con nivel de detalle.
lado :: Int -> Dibujo Escher -> Dibujo Escher
lado 0 p = pureDib Blanco
lado n p = cuarteto (lado (n-1) p) (lado (n-1) p) (Rotar (dibujoT p)) (dibujoT p)

-- Por suerte no tenemos que poner el tipo!
noneto p q r s t u v w x = Apilar 1 2 (Juntar 1 2 p (Juntar 1 1 q r)) 
                            (Apilar 1 1 (Juntar 1 2 s (Juntar 1 1 t u)) 
                                        (Juntar 1 2 v (Juntar 1 1 w x)))

-- El dibujo de Escher:
escher :: Int -> Escher -> Dibujo Escher
escher 0 fig = Basica fig
escher n fig = noneto p q r s t u v w x
            where 
                p = esquina n (Basica fig)
                q = lado n (Basica fig)
                r = r270 (esquina n (Basica fig))
                s = Rotar (lado n (Basica fig))
                t = dibujoU (Basica fig)
                u = r270 (lado n (Basica fig))
                v = Rotar (esquina n (Basica fig))
                w = r180 (lado n (Basica fig))
                x = r180 (esquina n (Basica fig))

escherDib =  escher 5 Fig

interpEscher :: Output Escher
interpEscher Blanco = simple Blank
interpEscher Fig = trian2