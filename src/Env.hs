{-# LANGUAGE DeriveDataTypeable #-}
module Env where

import Random
import Data.Data

--Data type to represent the elements present in the environment
data Element = Dirt {row :: Int, column :: Int} 
              | Obstacle {row :: Int, column :: Int}  
              | Playpen {row :: Int, column :: Int}  
              | Baby {row :: Int, column :: Int, wcompany :: Bool}  
              | Robot {row :: Int, column :: Int, wcompany :: Bool} deriving (Show, Data, Typeable)


--Set board for the simulation
--Arguments: Number of rows, no. of cols, no. of obstacles, no. of robots, no. of babys, initial amount of dirt 
--Return: An array of Elements, the initialized bard
initializeEnv :: Int -> Int ->  Int -> Int -> Int -> Int -> [Element]
initializeEnv rows cols obsts robots babys dirt = finalEnv
    where
        playpenEnv = allocatePlaypen rows cols babys
        obstEnv = allocateObstacles rows cols obsts playpenEnv 
        robotEnv = allocateRobots rows cols robots obstEnv
        babyEnv = allocateBabys rows cols babys robotEnv
        finalEnv = allocateDirt rows cols dirt babyEnv

------------------------------------------------GENERAL-------------------------------------------------


--Scan all elements to ensure the position is not taken
freePos :: Int -> Int -> [Element] -> Bool
freePos x y [] = True 
freePos x y (e:rest) = if row e == x && column e == y 
                        then False
                        else freePos x y rest  

--Validates wether a given position is inside the board or not
--Arguments: x y: coordinates to validate, maxx, maxy: max values of row-column presents in the board 
withinBounds :: Int-> Int -> Int -> Int -> Bool
withinBounds x y maxx maxy = x > 0 && x <= maxx && y >0 && y <= maxy

-- LLEVAR LUEGO QUE EL TABLERO NO ESTE LLENO
--generate position and validate disponibility in the board
generateRandomPos :: Int -> Int -> [Element]-> (Int, Int)
generateRandomPos maxX maxY board | freePos newx newy board = (newx, newy)
                            | otherwise = generateRandomPos maxX maxY board
                            where 
                                newx = myRandom 1 maxX
                                newy = myRandom 1 maxY


------------------------------------------------PLAYPEN-------------------------------------------------

--GENERATE THE PLAYPEN In A MORE GENERAL WAY (MAYBE TAKING AN INITIAL POSITION AND EXPANDING IT)
--allocates the 1xp plapypen whitin a rxc board 
allocatePlaypen :: Int -> Int -> Int -> [Element]
allocatePlaypen r c p = newEnv
                       where
                            (initialx, initialy) = generateRandomPos r c []--new board empty
                            (env1, newp) = allocatePlaypenWDir r c initialx initialy 0 1 (p-1) [Playpen initialx initialy]
                            (newEnv, lastp) = allocatePlaypenWDir r c initialx initialy 0 (-1) newp env1

--Allocates a specific playpen piece and recursivelly call to allocate next pos
--Arguments:
--r: rows of the board, 
--c: columns, 
--x, y: coordinates of the previous piece, 
--rp: amount to add to x, 
--cp: amount to add to y, 
--p : amount of pieces to place, 
--env: environment
allocatePlaypenWDir :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> [Element] -> ([Element], Int)
allocatePlaypenWDir r c x y rp cp 0 env = (env, 0)
allocatePlaypenWDir r c x y rp cp p env | freePos nextx nexty env && withinBounds nextx nexty r c = (let (newEnv, newp) = allocatePlaypenWDir r c nextx nexty rp cp (p-1) ([Playpen nextx nexty] ++ env) in (newEnv, newp)) 
                                        | otherwise = (env, p)
                                        where
                                          nextx = x+rp
                                          nexty = y+cp

--Utilizando el createElement fundir esto en un metodo que reciba el nombre de los elementos a crear
------------------------------------------------Obstacles-------------------------------------------------
allocateObstacles :: Int -> Int -> Int -> [Element] -> [Element] 
allocateObstacles rows cols 0 env  = env  
allocateObstacles rows cols obsts env  = allocateObstacles rows cols (obsts-1) newEnv
                                        where
                                            (x, y) = generateRandomPos rows cols env
                                            newEnv = env ++ [Obstacle x y]


------------------------------------------------Robots-------------------------------------------------
allocateRobots :: Int -> Int -> Int -> [Element] -> [Element] 
allocateRobots rows cols 0 env  = env  
allocateRobots rows cols robots env  = allocateRobots rows cols (robots-1) newEnv
                                        where
                                            (x, y) = generateRandomPos rows cols env
                                            newEnv = env ++ [Robot x y False]

------------------------------------------------Babys-------------------------------------------------
allocateBabys :: Int -> Int -> Int -> [Element] -> [Element] 
allocateBabys rows cols 0 env  = env  
allocateBabys rows cols babys env  = allocateBabys rows cols (babys-1) newEnv
                                        where
                                            (x, y) = generateRandomPos rows cols env
                                            newEnv = env ++ [Baby x y False]


------------------------------------------------Dirt-------------------------------------------------
allocateDirt :: Int -> Int -> Int -> [Element] -> [Element] 
allocateDirt rows cols 0 env  = env  
allocateDirt rows cols dirt env  = allocateDirt rows cols (dirt-1) newEnv
                                        where
                                            (x, y) = generateRandomPos rows cols env
                                            newEnv = env ++ [Dirt x y]

