module Main where
import Random
import Env
 

main :: IO ()
main = do
  print (initializeEnv 5 5 1 1 2 2)
  -- print (allocateObstacles 3 3 1 [])
  -- print (initializeEnv 3 3 0 0 2 0)
  -- print (generateRandomPos 3 3 [Obstacle 1 2, Obstacle 1 1,Obstacle 1 0])
  -- print (test2 1 2)
  -- print (row (Robot 3 2 True))
  -- putStrLn "Hello Gaby"
