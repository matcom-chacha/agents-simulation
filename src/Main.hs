module Main where
import Random
import Env
import EnvChanges
 

main :: IO ()
main = do
  -- let newEnv = if 0 /= 1 && 2 /=  
  --                               then reallocateObstacleFromTo 0 1 0 2 [Baby 0 0 False, Obstacle 0 1]
  --                               else [Baby 0 0 False, Obstacle 0 1]
  -- print(newEnv)
  -- print (reallocateObstacleFromTo 0 1 0 2 [Baby 0 0 False, Obstacle 0 1])

  let env = [Baby 0 0 False, Obstacle 0 1, Obstacle 0 2]
  let x = 0
  let y = 0
  -- print( moveBabies 3 3 [Baby 1 2 False, Obstacle 0 0])
  let randDir = myRandom 5
  print(randDir)
  let (xdir, ydir) = getDirection randDir
  print(xdir)
  print(ydir)
  let (nextx, nexty) = nextValidPos x y xdir ydir 5 5 env
  print(nextx)
  print(nexty)
  let finalEnv = reorganizeRoom x y xdir ydir nextx nexty env
  print(finalEnv)

  -- print (not (wcompany (Baby 1 2 False)))
  -- print(myRandom 5)
  -- print( getDirection 2)
  -- print (takeBabies [Baby 1 2 False, Dirt 0 0, Baby 3 4 True])
  -- print (initializeEnv 5 5 1 1 2 2)
  -- print (allocateObstacles 3 3 1 [])
  -- print (initializeEnv 3 3 0 0 2 0)
  -- print (generateRandomPos 3 3 [Obstacle 1 2, Obstacle 1 1,Obstacle 1 0])
  -- print (test2 1 2)
  -- print (row (Robot 3 2 True))
  -- putStrLn "Hello Gaby"
