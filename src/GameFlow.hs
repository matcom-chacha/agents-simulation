module GameFlow where

import Env
import EnvChanges
import Agents
--Mueve los bebes
--Si el tiempo es multiplo de t genera suciedad
--Mueve los robots

--Nota: todos los robots en simulacion deben ser del mismo tipo, se registrara el tipo de estos y se mandara a mover con el metodo acorde


--Por ahora devolver env inicial env final, tiempo de simulacion y resultado obtenido (robot gano o perdio, empate)
--quizas otras estadisticas como ctdad de casillas sucias, ctdad de bebes sueltos, en corral
--tambien los datos iniciales, rows, cols, numero de cada cosa con la que se empezo 

gameCicle :: Int -> Int -> Int -> Int -> Int-> Int -> [Element] -> [Element] -> [Element] -> Bool -> IO ()
-- gameCicle rows cols robotTypes randomVariationTime simTime currentTime env= finalEnv--time finito stop simulation
-- gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv True = putStrLn "Game Over"
gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv True = printState env babiesEnv dirtEnv 1
gameCicle rows cols robotTypes randomVariationTime simTime currentTime env babiesEnv dirtEnv False = do
            let a = 1 in printState env babiesEnv dirtEnv a
            let babiesEnv = moveBabies rows cols env 
                dirtEnv = if ((mod currentTime randomVariationTime) == 0 )
                        then createDirt rows cols env babiesEnv -- if t where oldEnv es el de antes de mover los bebes y newEnv el resultante
                        else babiesEnv
                (envChangedByRobot, finalEnv) = moveRobots rows cols dirtEnv robotTypes
                envChanged = envChangedByRobot --aqui se puede simplement comprobar si el env que entro es diferente al final, o sino decir ya que cuando los robots no pueden moverse se acabo el juego,pq los ninnos pueden decidir no dejarlos salir again
                gameOver = isGameOver rows cols finalEnv
                finito = simTime == currentTime || gameOver || not envChanged in gameCicle rows cols robotTypes randomVariationTime simTime (currentTime+1) finalEnv babiesEnv dirtEnv finito
                

printState :: [Element] -> [Element] -> [Element] -> Int -> IO ()
printState finalEnv babiesEnv dirtEnv n = do
    putStrLn "babiesEnv:"
    putStrLn (show babiesEnv) 
    putStrLn "DirtyEnv:"
    putStrLn (show dirtEnv) 
    putStrLn "RobotEnv:"
    putStrLn (show finalEnv)                 

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
