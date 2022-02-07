-- {-# LANGUAGE DeriveDataTypeable #-}
module Main where
import Random
import Env
import EnvChanges
import Agents
-- import Data.Data
import Data.Matrix

main :: IO ()
main = do
  let rows = 5
  let cols = 5
  let env = [Baby 1 1 True, Robot 1 1 True, Baby 1 2 False, Obstacle 3 2, Dirt 3 3]--no entra al centro de la matriz

  let (result, newEnv) = findDirt rows cols env (Robot 1 1 True)

  print result
  print newEnv
  -- let env = [Baby 1 1 True, Robot 1 1 True, Baby 1 2 False, Obstacle 3 2, Dirt 3 3]--no entra al centro de la matriz
  -- let newEnv = reallocateRobot (Robot 1 1 True) 2 2 env
  -- print newEnv

  -- let env = [Baby 1 1 False, Baby 1 2 False, Obstacle 3 2, Dirt 3 3]--no entra al centro de la matriz
  -- let newEnv = reallocateElementFromTo "Obstacle" 3 2 False 3 1 env False
  -- print newEnv

  -- let isAt = isElementVAtXY "Obstacle" 3 2 False env False
  -- print isAt
  
  -- let newEl = createElement "Obstacle" 0 0 False
  -- print newEl
  
  -- let rows = 5
  -- let cols = 5
  -- let env = [Baby 1 1 False, Baby 1 2 False, Obstacle 3 2, Dirt 3 3]--no entra al centro de la matriz
  -- let (nextStep, dist ) = bfsForDirt rows cols (Robot 1 1 True) "Dirt" ["Robot", "Obstacle"] env
  -- print(nextStep)
  -- print(dist)

  -- let env = [Baby 1 1 False, Baby 1 2 False, Obstacle 3 3, Dirt 3 2]
  -- let env = [Baby 1 1 False, Baby 1 2 False, Obstacle 3 3]
  -- let initialMatrix = matrix rows cols $ \(i, j)-> (-1)
  -- let myMatrix = setElem 0 (1, 1) initialMatrix
  -- print( myMatrix)

  -- print(nrows myMatrix)
  -- print(ncols myMatrix)


  -- let adjacents = getFreeAdyacents 1 1 rows cols env myMatrix 1 4
  -- print adjacents
  -- let (xdir, ydir) = getDirection 2
  -- let  np = nextPos 1 1 xdir ydir rows cols env
  -- print( np)

  -- let (bfsMatrix, destination) = bfsForDirtAux [(1,1,0)] rows cols env myMatrix
  -- print bfsMatrix
  -- print destination
  -- let (dirtx, dirty, distance) = destination
  -- let path = followTraceFromTo dirtx dirty distance 1 1 bfsMatrix-----------------------------------------------
  -- print(path)
  -- let nextTile = chooseNextTile path 2
  -- print nextTile
  -- let (nextStep, dist ) = bfsForDirt rows cols (Robot 1 1 False) env
  -- print(nextStep)
  -- print(dist)

-- let (nextx, nexty)
  -- print( myMethod [2])

  -- let mat = matrix 4 4 $ \(i,j) -> 2*i- j
  -- let mat = matrix 4 4 (\(i,j) -> 2*i- j)
  -- print(mat)
    -- print (removeDirtAt 0 3 [Dirt 0 3 , Baby 0 1 False ])
  -- let oldEnv = [Baby 0 0 False, Baby 1 1 False, Obstacle 3 3]
  -- let newEnv = [Baby 0 1 False, Baby 1 1 False, Obstacle 3 3]
  -- let gridPos = getGridPos 5 5 0 0
  -- let babies = takeBabies oldEnv oldEnv
  -- let gridPartners = getGridPartners babies gridPos
  -- let availablePos = getGridFreePos gridPos newEnv 
  -- print( availablePos)
  -- let dirtToGenerate = getCorrespondingDirt gridPartners
  -- print( dirtToGenerate)
  -- let babysDirt = allocateNewDirt dirtToGenerate availablePos newEnv
  -- print(babysDirt)

  -- print(removeNthElement 2 [(1,0), (1,1), (1,2)]) 

  -- let newEnv = [Baby 0 0 False, Baby 0 2 False, Obstacle 0 1]
  -- print (createDirt 3 3 oldEnv newEnv) 

  -- let a = [] ++ [Baby 1 2 True] ++ [Playpen 1 3] ++ []
  -- print a
  -- let env = [Baby 0 0 False, Baby 0 2 False, Playpen 0 3,  Obstacle 0 1]
  -- print( takeBabies env env)
  -- print( inPlayPen (Baby 0 0 False) env)

  -- print( inPlayPen (Baby 0 0 False) [Baby 0 0 False, Playpen 0 0,  Obstacle 0 1] )
  -- let result = show $ toConstr (X 3)
  -- let result = show $ toConstr (Baby 1 2 False)
  
  -- let result = toConstr (Baby 1 2 False)
  -- let comparison = (show $ toConstr (Baby 1 2 False)) == "Baby"
  -- print result
  -- print comparison

  -- let newEnv = if 0 /= 1 && 2 /=  
  --                               then reallocateObstacleFromTo 0 1 0 2 [Baby 0 0 False, Obstacle 0 1]
  --                               else [Baby 0 0 False, Obstacle 0 1]
  -- print(newEnv)
  -- print (reallocateObstacleFromTo 0 1 0 2 [Baby 0 0 False, Obstacle 0 1])

  -- let env = [Baby 0 0 False, Obstacle 0 1, Obstacle 0 2]
  -- let x = 0
  -- let y = 0
  -- -- print( moveBabies 3 3 [Baby 1 2 False, Obstacle 0 0])
  -- let randDir = myRandom 5
  -- print(randDir)
  -- let (xdir, ydir) = getDirection randDir
  -- print(xdir)
  -- print(ydir)
  -- let (nextx, nexty) = nextValidPos x y xdir ydir 3 3 env
  -- print(nextx)
  -- print(nexty)
  -- let finalEnv = reorganizeRoom x y xdir ydir nextx nexty env
  -- print(finalEnv)

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
