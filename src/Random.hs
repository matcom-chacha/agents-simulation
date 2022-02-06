module Random where

import System.IO.Unsafe  -- be careful!                                          
import System.Random 
 

-- c :: Int 
-- c = unsafePerformIO (getStdRandom (randomR (min, max)))

--Generate random number withing the range 0:max-1
myRandom :: Int -> Int-> Int 
myRandom min max = unsafePerformIO (getStdRandom (randomR (min, max)))
