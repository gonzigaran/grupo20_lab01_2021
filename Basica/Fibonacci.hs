module Basica.Fibonacci where
import Dibujo
import Interp
import Graphics.Gloss.Data.Picture ( Picture( Blank ) )

-- Supongamos que eligen.

data Fibonacci = Blanco | Fig

sucFibonacci :: Int -> Int
sucFibonacci 0 = 1
sucFibonacci 1 = 2
sucFibonacci n = (sucFibonacci (n-1)) + (sucFibonacci (n-2))

-- Por suerte no tenemos que poner el tipo!
duo n p q = Juntar (sucFibonacci n) (sucFibonacci (n-1))  p q

-- El dibujo de Escher:
fibonacci :: Int -> Fibonacci -> Dibujo Fibonacci
fibonacci 0 fig = Basica fig
fibonacci n fig = duo n p q 
            where 
                p = (Basica fig)
                q = r270 (fibonacci (n-1) fig) 

fiboDib =  fibonacci 30 Fig

interpFibo :: Output Fibonacci
interpFibo Blanco = simple Blank
interpFibo Fig = circdiagBorder