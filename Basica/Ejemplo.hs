module Basica.Ejemplo where
import Dibujo
import Interp

type Basica = Bool
ejemplo :: Dibujo Basica
ejemplo = Basica True

interpBas :: Output Basica
interpBas _ = trian1
