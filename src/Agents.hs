{-# LANGUAGE DeriveDataTypeable #-}

module Agents where

import Env
import EnvChanges
import Data.Data
import Data.Matrix

-------------------------------------------------Agent 1------------------------------------------------------------


--Mantener la casa limpia 
--Robot da 1 paso sin ninno y 2 con el
--Al llegar a una casilla con bebe inmediatamente lo carga
--Puede dejar a un bebe en cualquier casilla(libre o con un corral vacio), se mantienen ahi ambos por ese turno
--Al llegar a una casilla con suciedad elige si limpiar o moverse en el proximo turno

-- --SI EL BEBE CARGA UN ROBOT MOVERLO A EL TAMBIEN
-- moveR2B2 :: [Element] -> Element -> [Element]
-- moveR2B2 env robot | uponDirt env robot = cleanDirt env robot
--                   | wChild && length (freeBabies) == 0 = findDirt env robot
--                   | wChild && length (freeBabies) > 0 = findPlaypen env robot
--                   | not wChild = stimateBestAnswer env robot -- entre este y el paso de limpiar suciedad en se podria valorar que tan cerca esta el bebe y entonces actuar
--                 --   | otherwise = False
--                   where
--                       wChild = wcompany robot
--                       freeBabies = takeBabies env env

--return wether a given robot is positioned over a dirty tile or not
uponDirt :: [Element] -> Element -> Bool 
uponDirt [] robot = False
uponDirt (Dirt x y : rest) robot | x == row robot && y == column robot = True
                                 | otherwise = uponDirt rest robot
uponDirt (e: rest) robot = uponDirt rest robot

--Remove dirt in a tile with the robot coordinates
cleanDirt :: [Element] -> Element -> [Element]
cleanDirt env robot = removeDirtAt (row robot) (column robot) env

--REVISADO
--remove a given element form the environment SI FUNCIONA EL TOCONST LLEVAR ESTO A UN METODO GENERICO
removeDirtAt :: Int -> Int -> [Element] -> [Element]
removeDirtAt x y [] = []
removeDirtAt x y (e:rest) = if row e == x && column e == y && ((show $ toConstr (e)) == "Dirt")
                                then rest
                                else [e] ++ removeDirtAt x y rest  

--Para el bfs tener en cuenta que:
--Se debe ir llevando una lista con las posiciones libre encontradas y el numero con el que fueron descubiertas
--Parar cuando se encuentre el objetivo y asegurar ponerle numero
--Para encontrar el camino de regreso ir virando y pidiendo de los adyacentes en la lista de vistos uno
--la ctdad anterior (o menor) de encontrado
--tomar el ultimo de esta lista antes de encontrar a la fuente que seria 0, y aqui seria el proximo paso

-- --Stimate distance to closest dirt and move towards it
-- findDirt :: Int -> Int -> [Element] -> Element -> [Element]
-- findDirt rows cols env robot = finalEnv
--                     where
--                         ( coord, distance) = bfsForDirt rows cols robot env 
--                         x, y = coord
--                         newEnv = removeRobot robot env
--                         newEnv = addRobot x y env 

-- --Add robot to a given position in the env
-- addRobot x y env 

-- --Remove robot from a given position in the env
-- removeRobot robot env

--BFS from robot to dirt
--return the distance from the given robot to the closest dirty tile
--and the next coordinates to visit in orden to reach the dirt

-- --ANNADIR ROWS COLS
-- bfsForDirt :: Int -> Int -> Element -> [Element] -> ((Int, Int), Int)
-- bfsForDirt rows cols robot env = ((nextx, nexty), distance)
--                         where 
--                             robotx = row x
--                             roboty = column x
--                             matrix = matrix rows cols $ \(i, j)-> (-1)--separar esta lista y el de abajo con un metodo propio del bfs
                            --    discoverTimes = setElem 0 (robotx, roboty) matrix
--                             (tilesVisited, dirtFound) = bfsForDirtAux [(robotx,roboty, 0)] rows cols env discoverTimes
--                             (dirtx, dirty, distance) = dirtFound
--                             (nextx, nexty) = followTraceFromTo dirtx dirty distance robotx roboty distanceRequired tilesVisited


--bfs from a source x,y to closest dirt. 
--Returns a tuple with: a matrix with the visited positions and their descovering times
--and a tuple with the dirt discovered
bfsForDirtAux :: [(Int, Int, Int)] -> Int -> Int -> [Element] -> Matrix Int -> (Matrix Int, (Int, Int, Int))
bfsForDirtAux [] rows cols env discoverTimes = (discoverTimes, (-1, -1, -1))--Not found
bfsForDirtAux ((x, y, z):rest) rows cols env discoverTimes | isDirt x y env = (discoverTimes, (x, y, z))--objective found
                                | otherwise  = bfsForDirtAux tilesToAnalize rows cols env newDiscoverTimes
                                    where
                                        -- newDiscoveredTimes = setElem z (x,y) discoveredTimes--SETEAR ESTO APENAS SE ENCUENTRA
                                        freeAdys = getFreeAdyacents x y rows cols env discoverTimes (z+1) 4
                                        newDiscoverTimes = setDiscoverTimes freeAdys discoverTimes--SETEAR ESTO APENAS SE ENCUENTRA
                                        tilesToAnalize = rest ++ freeAdys


setDiscoverTimes :: [(Int, Int, Int)] -> Matrix Int -> Matrix Int
setDiscoverTimes [] discoverTimes = discoverTimes 
setDiscoverTimes ((x, y, dt):rest) discoverTimes = setDiscoverTimes rest newDiscoverTimes
                                                        where
                                                            newDiscoverTimes = setElem dt (x, y) discoverTimes

--Por cada uno de sus adyacentes verificar que no sea dirt o que este libre

--Check wether a Dirty tile is present in x, y
isDirt :: Int -> Int -> [Element] -> Bool
isDirt x y [] = False
isDirt x y (e:rest) = if row e == x && column e == y && ((show $ toConstr (e)) == "Dirt")
                        then True
                        else isDirt x y rest  

--No se puede pasar por encima de obstaculos 

--Returns adyacents of x, y that are no occupied by obstacles =/= any other element
getFreeAdyacents :: Int -> Int -> Int -> Int -> [Element] -> Matrix Int -> Int -> Int -> [ (Int, Int, Int)]
getFreeAdyacents x y rows cols env visitedMatrix distance 0 = []
getFreeAdyacents x y rows cols env visitedMatrix distance n = adyacent ++ getFreeAdyacents x y rows cols env visitedMatrix distance (n-1)
                    where
                        (xdir, ydir) = getDirection n
                        (nextx, nexty) = nextPos x y xdir ydir rows cols env-- /= -1 is an available position
                        adyacent = if nextx /= -1 && ((visitedMatrix ! (nextx, nexty)) == -1 ) --it has not been visited yet
                                    then 
                                        [(nextx, nexty, distance)]
                                    else []
                                 
                                    -- adayacents1 = getDirection 2
                                    -- adayacents2 = getDirection 3
                                    -- adayacents3 = getDirection 4

--Returns is the tile is not occupied by a robot or obstacle
freeOfRobotObst :: Int -> Int -> [Element] -> Bool
freeOfRobotObst x y [] = True 
freeOfRobotObst x y (e:rest) = if row e == x && column e == y && (((show $ toConstr (e)) == "Robot")|| ((show $ toConstr (e)) == "Obstacle"))
                        then False
                        else freeOfRobotObst x y rest  

nextPos :: Int -> Int -> Int -> Int -> Int -> Int -> [Element] -> (Int, Int)
nextPos x y xdir ydir rows cols env | withinBounds nextx nexty rows cols && freeOfRobotObst nextx nexty env = (nextx, nexty) 
                               | otherwise = (-1, -1)
                                  where 
                                      nextx = x + xdir
                                      nexty = y + ydir

-- --Follow the path from source to destination in a list returned by a bfs
-- --distanceRequired tell how many steps away from the destination are required
-- followTraceFromTo dirtx dirty distance robotx roboty distanceRequired tilesVisited

-- --move robot towards closest playpen EN ESTOS CASOS PASAR LA MAYOR CTDAD DE PASOS QUE PUEDE DAR EL ROBOT
-- findPlaypen :: [Element] -> Element -> [Element]
-- findPlaypen env robot-- Aqui bajar al ninno si estas en el corral

-- --Find closest activity to do between chase babies or dirt
-- stimateBestAnswer --Usar findBaby pero devolviendo este un camino y segun la distancia proseguir
-- --HAcer un etodo auxiliar para devolver el camino al bebe y otro a la cuna que utilicen todos los metodos

-- --move robot towards closest baby EN ESTOS CASOS PASAR LA MAYOR CTDAD DE PASOS QUE PUEDE DAR EL ROBOT
-- findBaby :: [Element] -> Element -> [Element] --TENER EN CUENTA QUE EL BEBE NO ESTE EN LA CUNA NI CARGADADO POR OTRO ROBOT
-- findBaby env robot


-- -- --Return a list with the free babies in the given environment (those outisde of playpens and that are not carried by any robot)
-- -- getFreeBabies :: [Element] -> [Element] same as takeBabies
-- -- getFreeBabies env

--Pasos a seguir por el robot:
--Si tiene un ninno en brazos y no hay mas ninnos sueltos limpiar. Calcular la distancia min al churre por bfs
--Si tiene un ninno en brazos y hay mas sueltos dejarlo en la cuna mas cercana limpiando en el camino ( tratar de no bloquear esta)
    --Sino Calcular la distancia min a los ninnos y el churre por bfs. Seguir a uno de estos, el que este mas cercano

--Si esta parado sobre churre limpiar

--Moverse en la direccion elegida si no se eligio limpiar. (De tener un ninno en brazos 2 pasos de ser posible)

-- IMPORTANTE
--Si la basura rodea al ninno y este no se puede mover no limpiar y dejar libre hasta que el resto no este listo


--Casos de parada de la simulacion:
--El env que devuelve el robot es el mismo y el que devuelven los bebes tambien


--Valorar la posibilidad de tener mas de 1 agente en juego y que entre estos se repartan las tareas (Agentes sociables)


-------------------------------------------------Agent 2-------------------------------------------------------------------

--Agente proactivo-> objetivo capturar los ninnos

--Si tiene un ninno a 2 o menos pasos de distancia (y no carga otro) acercarse (aunque este sobre suciedad)

-- moveC3PO :: [Element] -> [Element]
--Como es mas fino solo persigue a los ninnos, no limpia