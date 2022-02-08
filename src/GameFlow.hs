module GameFlow where

import Env
import EnvChanges
import Agents
import Data.Data
import Data.Matrix


-- -simTime: max time to keep on simulation
startSimulation :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int-> IO ()
startSimulation rows cols obsts robots babys dirt robotTypes randomVariationTime simTime = do
        let
            initialEnv = initializeEnv rows cols obsts robots babys dirt in gameCicle rows cols robotTypes randomVariationTime simTime 0 initialEnv [] [] False 0

--Main cicle of the game. Call for environment random changes and for the robots response.
gameCicle :: Int -> Int -> Int -> Int -> Int-> Int -> [Element] -> [Element] -> [Element] -> Bool -> Int -> IO ()
gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv True fLegend= printStadistics env dirtEnv currentTime rows cols fLegend
gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv False fLegend = do
            printState env dirtEnv currentTime rows cols
            let babiesEnv = moveBabies rows cols env 
                dirtEnv = if ((mod currentTime randomVariationTime) == 0 )
                        then createDirt rows cols env babiesEnv 
                        else babiesEnv
                (envChangedByRobot, finalEnv) = moveRobots rows cols dirtEnv robotTypes
                envChanged = envChangedByRobot
                gameOver = isGameOver rows cols finalEnv
                tLimitExceed = simTime == currentTime
                fLegend = if tLimitExceed 
                            then 0
                          else
                              if gameOver
                              then 1
                              else 2  
                finishSim = tLimitExceed || gameOver || not envChanged in gameCicle rows cols robotTypes randomVariationTime simTime (currentTime+1) finalEnv babiesEnv dirtEnv finishSim fLegend

--Translate the env to a matrix
getEnvAsMatrix :: [Element] -> Int -> Int -> Matrix [Char]
getEnvAsMatrix env rows cols = fmatrix
    where
        bmatrix = matrix rows cols $ \(i, j)-> "     "
        fmatrix = fillMatrix env bmatrix

--Populate the matrix with the simulation state
fillMatrix :: [Element] -> Matrix [Char] -> Matrix [Char]
fillMatrix [] board = board 
fillMatrix (e:rest) board = fillMatrix rest newBoard
                            where
                                x = row e
                                y = column e
                                elementName = show $ toConstr (e)
                                wc = if (elementName == "Baby" || elementName == "Robot") then wcompany e else False
                                oldString = board ! (x,y)
                                mRepr = getStringForMatrix oldString elementName wc
                                newBoard = setElem mRepr (x, y) board

--Get the corresponding string for a tile in the matrix representing the board
getStringForMatrix :: String -> String -> Bool -> String
-- getStringForMatrix oldString elementName wc = "old"
getStringForMatrix oldString elementName wc = newString
    where 
        elementRepresentation = elementLegend elementName wc
        initialChar = oldString !! 0
        finalChar = oldString !! 4
        newString = if elementName == "Obstacle" || elementName == "Playpen"
            then
                elementRepresentation
            else
                if (oldString !! 2) /= ' '--there was already 1 element in the tile
                then 
                    if (oldString !! 1) /= ' '
                    then "-----"--there was already 3 elements in the tile
                    else [initialChar] ++ [oldString !! 2] ++ " " ++ elementRepresentation ++ [finalChar]
                else 
                    if (oldString !! 1) /= ' ' && (oldString !! 3) /= ' '--two elements in the tile
                    then [initialChar] ++ [oldString !! 1] ++ elementRepresentation ++ [oldString !! 3] ++ [finalChar]
                    else [initialChar] ++ " " ++ elementRepresentation ++ " " ++ [finalChar]--first element found in that tile

--Works like a dictionary from every element in the simulation to their corresponding representation
elementLegend :: String -> Bool -> String
elementLegend elementName wc = case elementName of 
                                                    "Dirt" -> "D"
                                                    "Obstacle"-> " /// " 
                                                    "Playpen" -> "|   |"
                                                    "Baby" -> if wc then "B" else "b"
                                                    "Robot" -> if wc then "R" else "r"
                                                    
--Print stadistics about the simulation
printStadistics :: [Element] -> [Element] -> Int -> Int -> Int -> Int -> IO ()
printStadistics finalEnv dirtEnv time rows cols fLegend = do
                                                  printState finalEnv dirtEnv time rows cols 
                                                  putStrLn "Simulation Stopped"
                                                  let reasonOfCulmmination = if fLegend == 0
                                                                             then "Time Limit exceed"
                                                                             else
                                                                                 if fLegend == 1
                                                                                 then "Dirt Amount exceed 40 %"
                                                                                 else "No more moves available for robots"
                                                  putStrLn reasonOfCulmmination  
                                                  putStrLn "Stadistics:"
                                                  putStrLn "Board dimensions: "
                                                  putStrLn ("Rows: "++ show rows)
                                                  putStrLn ("Columns: "++ show cols)
                                                  putStrLn ("Simulation time: "++ show time ++ " s")
                                                  let dirtTiles = takeDirt finalEnv finalEnv
                                                  let dirtPercentange = (length dirtTiles) * 100 `div` (rows * cols)
                                                  putStrLn ("Dirt tiles: "++ show dirtPercentange ++ "%")
                                                  let babiesFree = takeBabies finalEnv finalEnv
                                                  putStrLn ("Unreached babies: " ++ show (length babiesFree))


--Print simulation state in a nice and easy way to undestand
printState :: [Element] -> [Element] -> Int -> Int -> Int -> IO ()
printState finalEnv dirtEnv t rows cols = do
    putStrLn ("Simulation time: " ++ show t)
    putStrLn "Environment's random variation:"
    let dirtMatrix = getEnvAsMatrix dirtEnv rows cols
    putStrLn (show dirtMatrix)
    putStrLn "Robot's response:"
    let finalMatrix = getEnvAsMatrix finalEnv rows cols
    putStrLn (show finalMatrix)

--Returns True is the amount of dirt in the env represents more than 40 percent of total tiles
isGameOver :: Int -> Int -> [Element] -> Bool
isGameOver rows cols env = amountOfDirt > fortyPercent
                                where
                                    dirtyElements = takeDirt env env
                                    amountOfDirt = length dirtyElements
                                    fortyPercent = (rows * cols * 40 ) `div` 100
