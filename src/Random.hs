mport System.IO.Unsafe  -- be careful!                                          
import System.Random 
 

c :: Int 
c = unsafePerformIO (getStdRandom (randomR (min, max)))