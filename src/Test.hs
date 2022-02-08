module Test where

testAgents :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> [Element] -> Bool -> IO ()
testAgents rows cols obsts robots babys dirt robotTypes randomVariationTime simTime board generateBoard = do
 
testAgents :: IO()
testAgents = do
    --Test1: matrix 5x5, 2 elements of each type, random dirt generation every 4 s, time limit 20 seconds
    let env1 = [Obstacle 2 1, Obstacle 3 4, Robot 1 2 False, Robot 5 5 False, Baby 5 3 False, Baby 2 2 False, Dirt 2 3, Dirt 5 1, Playpen 2 5, Playpen 3 5]
    --Agent1 R2B2 
    startSimulation 5 5 2 2 2 2 1 4 20 env1 False
    
    --Agent1 C3PO 
    startSimulation 5 5 2 2 2 2 2 4 20 env1 Fasle

     --Test1.1: matrix 5x5, 2 elements of each type, random dirt generation every 2 s, time limit 20 seconds

    --Agent1 R2B2 
    startSimulation 5 5 2 2 2 2 1 2 20 env1 False
    
    --Agent1 C3PO 
    startSimulation 5 5 2 2 2 2 2 2 20 env1 False


    --Test2: matrix 10x10, 3 elements of each type, random dirt generation every 4 s, time limit 50 seconds
    let env2 = [Obstacle 2 1, Obstacle 3 4, Robot 1 2 False, Robot 5 5 False, Baby 5 3 False, Baby 2 2 False, Dirt 2 3, Dirt 5 1, Playpen 2 5, Playpen 3 5, Obstacle 6 6, Playpen 4 5, Dirt 7 7, Baby 8 8 False, Robot 9 2 False ]
    --Agent1 R2B2 
    startSimulation 10 10 3 3 3 3 1 4 50 env2 False
    
    --Agent1 C3PO 
    startSimulation 5 5 3 3 3 3 2 4 50 env2 False

   --Test2.1: matrix 10x10, 3 elements of each type, random dirt generation every 2 s, time limit 50 seconds
    let env2 = [Obstacle 2 1, Obstacle 3 4, Robot 1 2 False, Robot 5 5 False, Baby 5 3 False, Baby 2 2 False, Dirt 2 3, Dirt 5 1, Playpen 2 5, Playpen 3 5, Obstacle 6 6, Playpen 4 5, Dirt 7 7, Baby 8 8 False, Robot 9 2 False ]
    --Agent1 R2B2 
    startSimulation 10 10 3 3 3 3 1 2 50 env2 False
    
    --Agent1 C3PO 
    startSimulation 5 5 3 3 3 3 2 2 50 env2 False

   --Test3: matrix 10x10, 3 elements of each type except 2 robots, random dirt generation every 4 s, time limit 100 seconds
    let env2 = [Obstacle 2 1, Obstacle 3 4, Robot 1 2 False, Baby 5 3 False, Baby 2 2 False, Dirt 2 3, Dirt 5 1, Playpen 2 5, Playpen 3 5, Obstacle 6 6, Playpen 4 5, Dirt 7 7, Baby 8 8 False, Robot 9 2 False ]
    --Agent1 R2B2 
    startSimulation 10 10 3 3 3 3 1 4 100 env2 False
    
    --Agent1 C3PO 
    startSimulation 5 5 3 3 3 3 2 4 100 env2 False

