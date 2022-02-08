module GameFlow where

import Env
import EnvChanges
import Agents
import Data.Data
import Data.Matrix

--Mueve los bebes
--Si el tiempo es multiplo de t genera suciedad
--Mueve los robots

--Nota: todos los robots en simulacion deben ser del mismo tipo, se registrara el tipo de estos y se mandara a mover con el metodo acorde

gameCicle :: Int -> Int -> Int -> Int -> Int-> Int -> [Element] -> [Element] -> [Element] -> Bool -> Int -> IO ()
-- gameCicle rows cols robotTypes randomVariationTime simTime currentTime env= finalEnv--time finito stop simulation
-- gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv True = putStrLn "Game Over"
gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv True fLegend= printStadistics env dirtEnv currentTime rows cols fLegend
gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv False fLegend = do
            printState env dirtEnv currentTime rows cols
            let babiesEnv = moveBabies rows cols env 
                dirtEnv = if ((mod currentTime randomVariationTime) == 0 )
                        then createDirt rows cols env babiesEnv 
                        else babiesEnv
                (envChangedByRobot, finalEnv) = moveRobots rows cols dirtEnv robotTypes
                envChanged = envChangedByRobot --aqui se puede simplement comprobar si el env que entro es diferente al final, o sino decir ya que cuando los robots no pueden moverse se acabo el juego,pq los ninnos pueden decidir no dejarlos salir again
                gameOver = isGameOver rows cols finalEnv
                tLimitExceed = simTime == currentTime
                fLegend = if tLimitExceed 
                            then 0
                          else
                              if gameOver
                              then 1
                              else 2  
                finishSim = tLimitExceed || gameOver || not envChanged in gameCicle rows cols robotTypes randomVariationTime simTime (currentTime+1) finalEnv babiesEnv dirtEnv finishSim fLegend

--Para los datos finales imprimir
--matriz final (dirt y robot)
--porciento de suciedad presente 
--causa por la que se paro la simulacion (ctdad de suciedad superada, tiempo de simulacion agotado, no hubo cambios)   

getEnvAsMatrix :: [Element] -> Int -> Int -> Matrix [Char]
getEnvAsMatrix env rows cols = fmatrix
    where
        bmatrix = matrix rows cols $ \(i, j)-> "     "
        fmatrix = fillMatrix env bmatrix

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

elementLegend :: String -> Bool -> String
elementLegend elementName wc = case elementName of 
                                                    "Dirt" -> "D"
                                                    "Obstacle"-> " /// " 
                                                    "Playpen" -> "|   |"
                                                    "Baby" -> if wc then "B" else "b"
                                                    "Robot" -> if wc then "R" else "r"
                                                    


--Por ahora devolver env inicial env final, tiempo de simulacion y resultado obtenido (robot gano o perdio, empate)
--quizas otras estadisticas como ctdad de casillas sucias, ctdad de bebes sueltos, en corral
--tambien los datos iniciales, rows, cols, numero de cada cosa con la que se empezo 

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








--Imprimir en cada iteracion info sobre
--t tiempo trascurrido
--matriz de dirt (movimiento aleatorio del medio)
--matriz de respuesta del robot
printState :: [Element] -> [Element] -> Int -> Int -> Int -> IO ()
printState finalEnv dirtEnv t rows cols = do
    putStrLn ("Simulation time: " ++ show t)
    putStrLn "Environment's random variation:"
    let dirtMatrix = getEnvAsMatrix dirtEnv rows cols
    putStrLn (show dirtMatrix)
    putStrLn "Robot's response:"
    let finalMatrix = getEnvAsMatrix finalEnv rows cols
    putStrLn (show finalMatrix)

-- -simTime: max time to keep on simulation
-- startSimulation :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int-> ([Element], Int, [Element])
-- startSimulation rows cols obsts robots babys dirt robotTypes randomVariationTime simTime = (initialEnv, finalState,finalEnv)
--         where
--             initialEnv = initializeEnv rows cols obsts robots babys dirt
--             (finalState, finalEnv) = gameCicle rows cols robotTypes randomVariationTime simTime 0 initialEnv


-- gameCicle :: Int -> Int -> Int -> Int -> Int-> Int -> [Element] -> (Int, [Element])
-- -- gameCicle rows cols robotTypes randomVariationTime simTime currentTime env= finalEnv--time finito stop simulation
-- gameCicle rows cols robotTypes randomVariationTime simTime currentTime env
--         | simTime == currentTime = (1, env) --maxSimTime reached Robots win
--         | gameOver = (3, env) --Robots lose
--         | not envChanged = (2, env)--si ya no hay mas movimientos  Tie
--         | otherwise = gameCicle rows cols robotTypes randomVariationTime simTime (currentTime+1) finalEnv--si ya no hay mas movimientos
--         where
--             babiesEnv = moveBabies rows cols env 
--             dirtEnv = if ((mod currentTime randomVariationTime) == 0 )
--                 then createDirt rows cols env babiesEnv -- if t where oldEnv es el de antes de mover los bebes y newEnv el resultante
--                 else babiesEnv
--             (envChangedByRobot, finalEnv) = moveRobots rows cols dirtEnv robotTypes
--             -- let envChanged = envChangedByBabies || envChangedByRandomDirVar || envChangedByRobot
--             envChanged = envChangedByRobot --aqui se puede simplement comprobar si el env que entro es diferente al final, o sino decir ya que cuando los robots no pueden moverse se acabo el juego,pq los ninnos pueden decidir no dejarlos salir again
--             gameOver = isGameOver rows cols finalEnv

--Returns True is the amount of dirt in the env represents more than 40 percent of total tiles
isGameOver :: Int -> Int -> [Element] -> Bool
isGameOver rows cols env = amountOfDirt > fortyPercent
                                where
                                    dirtyElements = takeDirt env env
                                    amountOfDirt = length dirtyElements
                                    fortyPercent = (rows * cols * 40 ) `div` 100
