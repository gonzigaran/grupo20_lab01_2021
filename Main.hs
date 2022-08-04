module Main where
import Graphics.Gloss
import Graphics.Gloss.Interface.IO.Display
-- import Graphics.UI.GLUT.Begin
import Dibujo
import Interp
import qualified Basica.Ejemplo as Ej
import qualified Basica.Escher as Es
import qualified Basica.Fibonacci as Fi

data Conf a = Conf {
    basic :: Output a
  , fig  :: Dibujo a
  , width :: Float
  , height :: Float
  , winname :: String
  }

ej x y = Conf {
                basic = Ej.interpBas
              , fig = Ej.ejemplo
              , width = x
              , height = y
              , winname = "Ejemplo"
              }

es x y = Conf {
                basic = Es.interpEscher
              , fig = Es.escherDib
              , width = x
              , height = y
              , winname = "Escher"
              }

fi x y = Conf {
                basic = Fi.interpFibo
              , fig = Fi.fiboDib
              , width = x
              , height = y
              , winname = "Fibonacci"
              }

-- Dada una computación que construye una configuración, mostramos por
-- pantalla la figura de la misma de acuerdo a la interpretación para
-- las figuras básicas. Permitimos una computación para poder leer
-- archivos, tomar argumentos, etc.
initial :: IO (Conf a) -> IO ()
initial cf = cf >>= \cfg ->
                  let x  = width cfg
                      y  = height cfg
                  in display win white . withGrid $ interp (basic cfg) (fig cfg) (-x/2,-y/2) (x,0) (0,y)
  where withGrid p = pictures [p, color grey $ grid 40 (-200,-200) 400 10]
        grey = makeColorI 120 120 120 25

cfg = fi 400 250
win = InWindow (winname cfg) (400, 250) (0, 0)
main = initial $ return cfg
