module Env where

import Random

--Data type to represent the elements present in the environment
-- data Element = Dirt Int Int | Obstacle Int Int | Playpen Int Int | Child Int Int Bool | Robot Int Int Bool deriving Show
data Element = Dirt {row :: Int, column :: Int} 
              | Obstacle {row :: Int, column :: Int}  
              | Playpen {row :: Int, column :: Int}  
              | Child {row :: Int, column :: Int, wcompany :: Bool}  
              | Robot {row :: Int, column :: Int, wcompany :: Bool} deriving Show


--Set board for the simulation
--Arguments: Number of rows, no. of cols, no. of obstacles, no. of robots, no. of babys, initial amount of dirt 
--Return: An array of Elements, the initialized bard
initializeEnv :: Int -> Int ->  Int -> Int -> Int -> Int -> [Element]
initializeEnv rows cols obsts robots babys dirt = env
    where
        playpenEnv = allocatePlaypen rows cols babys
        env = allocateObstacles rows cols obsts playpenEnv 
        -- obstEnv = allocateObstacles rows cols obsts playpenEnv 
--         robotEnv = allocateRobots rows cols robots obstEnv
--         babyEnv = allocateBabys rows cols babys robotEnv
--         finalEnv = allocateDirt rows cols dirt babyEnv

-- initializeEnv rows cols obsts robots babys dirt = env
--     where
--         playpenEnv = allocatePlaypen rows cols babys
--         obstEnv = allocateObstacles rows cols obsts playpenEnv 
--         robotEnv = allocateRobots rows cols robots obstEnv
--         babyEnv = allocateBabys rows cols babys robotEnv
--         finalEnv = allocateDirt rows cols dirt babyEnv

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
withinBounds x y maxx maxy = x >= 0 && x < maxx && y >=0 && y < maxy

-- LLEVAR LUEGO QUE EL TABLERO NO ESTE LLENO
--generate position and validate disponibility in the board
generateRandomPos :: Int -> Int -> [Element]-> (Int, Int)
generateRandomPos maxX maxY board | freePos newx newy board = (newx, newy)
                            | otherwise = generateRandomPos maxX maxY board
                            where 
                                newx = myRandom maxX
                                newy = myRandom maxY


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

--Generar una posicion inicial
-- X Generar un orientacion (Horizontal/ Vertical). Inicialmente se pondra directo horzontal
--Comenzar a annadir celdas del corral mientras se pueda hacia una direccion (Por ahora comenzando siempre a la derecha)
--Cuando ya no se pueda ir a la otra direccion o si ya se acabaron las celdas por disponer terminar

-- allocatePlaypen r c 0 = []
-- allocatePlaypen r c p = [Playpen x y] ++ [allocatePlaypen r c (p-1)]
--                 where 
--                     x = 
--                     y = 


------------------------------------------------Obstacles-------------------------------------------------
allocateObstacles :: Int -> Int -> Int -> [Element] -> [Element] 
allocateObstacles rows cols 0 env  = env  
allocateObstacles rows cols obsts env  = [Obstacle x y] ++ allocateObstacles rows cols (obsts-1) env
                                        where
                                            (x, y) = generateRandomPos rows cols env

-- allocateObstacles
-- allocateRobots
-- allocateBabys
-- allocateDirt