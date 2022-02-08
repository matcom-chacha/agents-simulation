{-# LANGUAGE DeriveDataTypeable #-}

module Agents where

import Env
import EnvChanges
import Data.Data
import Data.Matrix


--Try to move every robot in simulation
moveRobots :: Int -> Int -> [Element] -> Int -> (Bool, [Element])
moveRobots rows cols env robotTypes = moveRobotsAux rows cols env robots robotTypes False
                                            where
                                                robots = takeRobots env env

--Move every robot according to his type
moveRobotsAux :: Int -> Int -> [Element] -> [Element] -> Int -> Bool -> (Bool, [Element])--Eliminar de aqui y de abajo el Int devuelto en la tupla si no se necesita mas
moveRobotsAux rows cols env [] robotType envChanged = (envChanged, env) 
moveRobotsAux rows cols env (robot:rest) 1 envChanged = moveRobotsAux rows cols newEnv rest 1 nEnvChanged
                                                where
                                                    (couldMove, newEnv) = moveR2B2 rows cols env robot 
                                                    nEnvChanged = couldMove || envChanged                                               
moveRobotsAux rows cols env (robot:rest) 2 envChanged = moveRobotsAux rows cols newEnv rest 2 nEnvChanged
                                                where
                                                    (couldMove, newEnv) = moveC3PO rows cols env robot 
                                                    nEnvChanged = couldMove || envChanged                                               

--Return all robot currently in simulation
takeRobots :: [Element] -> [Element] -> [Element]
takeRobots [] env = []  
takeRobots (Robot x y c:rest) env = [Robot x y c] ++ takeRobots rest env
takeRobots (e:rest) env = takeRobots rest env

-------------------------------------------------Agent 1------------------------------------------------------------

moveR2B2 :: Int -> Int -> [Element] -> Element -> ( Bool, [Element])
moveR2B2 rows cols env robot | uponDirt env robot && result1 = (result1, env1)
                  | wChild && length (freeBabies) == 0 && result2 = (result2, env2)
                  | wChild && (length (freeBabies) > 0 || length (dirt) == 0 )  && result3 = (result3, env3)
                  | not wChild && result4 = (result4, env4)
                  | otherwise = (False, env)
                  where
                      wChild = wcompany robot
                      freeBabies = takeBabies env env
                      dirt = takeDirt env env
                      (result1, env1) = cleanDirt env robot
                      (result2, env2) = findDirt rows cols env robot 
                      (result3, env3) = findPlaypen rows cols env robot 
                      (result4, env4) = stimateBestAnswer rows cols env robot 


--Return the dirty tiles in the env
takeDirt :: [Element] -> [Element] -> [Element]
takeDirt [] env = []  
takeDirt (Dirt x y:rest) env = [Dirt x y] ++ takeDirt rest env
takeDirt (e:rest) env = takeDirt rest env

--Return wether a given robot is positioned over a dirty tile or not
uponDirt :: [Element] -> Element -> Bool 
uponDirt [] robot = False
uponDirt (Dirt x y : rest) robot | x == row robot && y == column robot = True
                                 | otherwise = uponDirt rest robot
uponDirt (e: rest) robot = uponDirt rest robot

--Remove dirt in a tile with the robot coordinates
cleanDirt :: [Element] -> Element -> (Bool, [Element])
cleanDirt env robot = (True, newEnv)--CAMBIAR AL METODO GENERAL
                    where
                        newEnv = removeDirtAt (row robot) (column robot) env

--remove a given element form the environment
removeDirtAt :: Int -> Int -> [Element] -> [Element]
removeDirtAt x y [] = []
removeDirtAt x y (e:rest) = if row e == x && column e == y && ((show $ toConstr (e)) == "Dirt")
                                then rest
                                else [e] ++ removeDirtAt x y rest  

--Stimate distance to closest dirt and move towards it
--Returns a tuple with a boolean indicating if the robot could find the objective and the environment (modified accordingly if the move was ejected)
findDirt :: Int -> Int -> [Element] -> Element -> (Bool, [Element])
findDirt rows cols env robot | x /= -1 =  (True, newEnv)
                             | otherwise = (False, env)
                    where
                        (coord, distance) = getNextStepToObjective rows cols robot "Dirt" ["Robot", "Obstacle"] env 
                        (x, y) = coord
                        newEnv = reallocateRobot robot x y env 

--Reallocate robot (and baby in case of carriying one) to another position
--If the destination has a baby in it arrangements are made so the robot can take it
reallocateRobot :: Element -> Int -> Int -> [Element] -> [Element]
reallocateRobot robot newX newY env | newX == -1 = env
                                    | otherwise = finalEnv
                            where
                                robotX = row robot
                                robotY = column robot
                                robotCarriesBaby = wcompany robot
                                robotWillTakeBaby = isElementVAtXY "Baby" newX newY False env True
                                robotWBaby = robotCarriesBaby || robotWillTakeBaby
                                babyEnv = if robotCarriesBaby
                                    then reallocateElementFromTo "Baby" robotX robotY True newX newY True env True
                                    else 
                                        if robotWillTakeBaby
                                            then reallocateElementFromTo "Baby" newX newY False newX newY True env True
                                        else 
                                            env
                                finalEnv = reallocateElementFromTo "Robot" robotX robotY robotCarriesBaby newX newY robotWBaby babyEnv True 

--Reallocate a specific element from a given postion to another 
reallocateElementFromTo:: String -> Int -> Int -> Bool -> Int -> Int -> Bool -> [Element] -> Bool -> [Element]
reallocateElementFromTo elementName sourceX sourceY wcompany destX destY nwcompany env babyOrRobot = finalEnv
                    where
                        newEnv = removeElementFrom elementName sourceX sourceY wcompany env babyOrRobot
                        newElement = createElement elementName destX destY nwcompany
                        finalEnv = newEnv ++ newElement

--Remove a specific element in a given position
removeElementFrom :: String -> Int -> Int -> Bool -> [Element] -> Bool -> [Element]
removeElementFrom elementName x y wc [] babyOrRobot = []
removeElementFrom elementName x y wc (e:rest) babyOrRobot = if row e == x && column e == y && ((show $ toConstr (e)) == elementName) && ((not babyOrRobot) || wcompany e == wc)
                                then rest
                                else [e] ++ removeElementFrom elementName x y wc rest babyOrRobot  

--Return an element with specific characteristics
createElement :: String -> Int -> Int -> Bool -> [Element]
createElement elementName sourceX sourceY wcompany = case elementName of "Baby" -> [Baby sourceX sourceY wcompany]
                                                                         "Robot" -> [Robot sourceX sourceY wcompany]
                                                                         "Obstacle" -> [Obstacle sourceX sourceY]
                                                                         "Dirt" -> [Dirt sourceX sourceY]
                                                                         "Playpen" -> [Playpen sourceX sourceY]

--Check wether a given element is in the environment (in a specific position) or not 
isElementVAtXY :: String -> Int -> Int -> Bool -> [Element] -> Bool -> Bool
isElementVAtXY elementName x y wc [] babyOrRobot = False
isElementVAtXY elementName x y wc (e:rest) babyOrRobot = if row e == x && column e == y && ((show $ toConstr (e)) == elementName) && ((not babyOrRobot) || wcompany e == wc)
                        then True
                        else isElementVAtXY elementName x y wc rest babyOrRobot  

--BFS from robot to dirt
--Return the distance from the given robot to the closest objective tile
--and the next coordinate to visit in orden to reach the objective
getNextStepToObjective ::  Int -> Int -> Element -> String -> [String] -> [Element] -> ((Int, Int), Int)
getNextStepToObjective rows cols robot destName elementsToAvoid env = ((nextx, nexty), distance)
                        where 
                            robotx = row robot
                            roboty = column robot
                            possibleSteps = if wcompany robot then 2 else 1
                            (tilesVisited, objFound) = bfs robotx roboty destName elementsToAvoid rows cols env
                            (objx, objy, distance) = objFound
                            path = if objx /= -1 
                                    then followTraceFromTo objx objy distance robotx roboty tilesVisited
                                    else [(-1,-1)]
                            (nextx, nexty) = if objx /= -1
                                                then chooseNextTile path possibleSteps
                                                else (-1,-1)

--Return the next tile to visit in a given path when a certain amount of steps can be taken by the robot
chooseNextTile :: [(Int, Int)] -> Int -> (Int, Int)
chooseNextTile path possibleSteps | possibleSteps >=2 && length path > possibleSteps = path !! possibleSteps
                                  | (length path) > 1 = path !! 1--added check for avoiding index too large error
                                  | otherwise = (-1,-1)


--Perform a bfs from source to closest kind of element (with destName)
bfs :: Int -> Int -> String -> [String] -> Int -> Int -> [Element] -> (Matrix Int, (Int, Int, Int))
bfs sourceX sourceY destName elementsToAvoid rows cols env = bfsAuxiliar [(sourceX, sourceY, 0)] destName elementsToAvoid rows cols env discoverTimes
    where
        dtmatrix = matrix rows cols $ \(i, j)-> (-1)
        discoverTimes = setElem 0 (sourceX, sourceY) dtmatrix                            

--BFS from a source x,y to closest kind of element. 
--Returns a tuple with: a matrix with the visited positions and their descovering times
--and a tuple with the objective discovered and its discover time
bfsAuxiliar :: [(Int, Int, Int)] -> String -> [String] -> Int -> Int -> [Element] -> Matrix Int -> (Matrix Int, (Int, Int, Int))
bfsAuxiliar [] destName elementsToAvoid rows cols env discoverTimes = (discoverTimes, (-1, -1, -1))--Not found
bfsAuxiliar ((x, y, z):rest) destName elementsToAvoid rows cols env discoverTimes | isThisKindOfElement destName x y env env = (discoverTimes, (x, y, z))--objective found
                                | otherwise  = bfsAuxiliar tilesToAnalize destName elementsToAvoid rows cols env newDiscoverTimes
                                    where
                                        freeAdys = getFreeAdyacents x y elementsToAvoid rows cols env discoverTimes (z+1) 4
                                        newDiscoverTimes = setDiscoverTimes freeAdys discoverTimes
                                        tilesToAnalize = rest ++ freeAdys

--Fill the matrix with the discover times of the elements in the list
setDiscoverTimes :: [(Int, Int, Int)] -> Matrix Int -> Matrix Int
setDiscoverTimes [] discoverTimes = discoverTimes 
setDiscoverTimes ((x, y, dt):rest) discoverTimes = setDiscoverTimes rest newDiscoverTimes
                                                        where
                                                            newDiscoverTimes = setElem dt (x, y) discoverTimes

--Check wether a X tile is present at some coordinates x, y (For babies it is assumed that babies with robots or o playpen are not obejectives)
isThisKindOfElement :: String -> Int -> Int -> [Element] -> [Element] -> Bool
isThisKindOfElement destName x y [] env = False
isThisKindOfElement destName x y (e:rest) env 
    | row e == x && column e == y && elementType == destName 
        && (elementType /= "Baby" || ( not (wcompany e) && not (isElementVAtXY "Playpen" x y False env False) )) 
            = True
    | otherwise = isThisKindOfElement destName x y rest env
        where
            elementType = show $ toConstr (e)

--Returns adyacents of x, y that are no occupied by obstacles =/= any other element
getFreeAdyacents :: Int -> Int -> [String] -> Int -> Int -> [Element] -> Matrix Int -> Int -> Int -> [ (Int, Int, Int)]
getFreeAdyacents x y elementsToAvoid rows cols env visitedMatrix distance 0 = []
getFreeAdyacents x y elementsToAvoid rows cols env visitedMatrix distance n = adyacent ++ getFreeAdyacents x y elementsToAvoid rows cols env visitedMatrix distance (n-1)
                    where
                        (xdir, ydir) = getDirection n
                        (nextx, nexty) = nextPos x y xdir ydir elementsToAvoid rows cols env-- /= -1 is an available position
                        adyacent = if nextx /= -1 && ((visitedMatrix ! (nextx, nexty)) == -1 ) --it has not been visited yet
                                    then 
                                        [(nextx, nexty, distance)]
                                    else []

--Returns wether and element belong to the list or not
elementInList :: Element -> [String] -> Bool
elementInList element [] = False
elementInList element (eName:rest) | (show $ toConstr (element)) == eName = True
                                   | otherwise = elementInList element rest

--Returns is the tile is not occupied by an element of the given list
freeOf :: Int -> Int -> [String] -> [Element] -> Bool
freeOf x y elementsToAvoid [] = True 
freeOf x y elementsToAvoid (e:rest) = if row e == x && column e == y && (elementInList e elementsToAvoid)
                        then False
                        else freeOf x y elementsToAvoid rest  

--Returns the coordinates resulting of following a given direction from a certain point 
nextPos :: Int -> Int -> Int -> Int  -> [String] -> Int -> Int -> [Element] -> (Int, Int)
nextPos x y xdir ydir elementsToAvoid rows cols env | withinBounds nextx nexty rows cols && freeOf nextx nexty elementsToAvoid env = (nextx, nexty) 
                               | otherwise = (-1, -1)
                                  where 
                                      nextx = x + xdir
                                      nexty = y + ydir

--Follow the path from source to destination in a list returned by a bfs
followTraceFromTo :: Int -> Int -> Int -> Int -> Int -> Matrix Int -> [(Int, Int)]--It is assumed that a path exist
followTraceFromTo currentX currentY 0 destX destY visitMatrix | currentX == destX && currentY == destY = [(currentX, currentY)]
                                                              | otherwise = [(-1,-1)]
followTraceFromTo currentX currentY distance destX destY visitMatrix | nextx /= -1 = (followTraceFromTo nextx nexty (distance -1) destX destY visitMatrix) ++ [(currentX, currentY)]
                            |otherwise = [(-1,-1)]
                            where
                                (nextx, nexty) = previousTileInPath currentX currentY (distance-1) visitMatrix

--Find which adjacent was discovered has the distance
previousTileInPath :: Int -> Int -> Int -> Matrix Int -> (Int, Int)
previousTileInPath currentX currentY distance visitMatrix = previousTileInPathInDir currentX currentY distance visitMatrix 4

--Find adjacents per direction and return the first one found with the given distance in the matrix
previousTileInPathInDir :: Int -> Int -> Int -> Matrix Int -> Int -> (Int, Int)
previousTileInPathInDir currentX currentY distance visitMatrix 0 = (-1,-1)
previousTileInPathInDir currentX currentY distance visitMatrix n 
        | withinBounds indexX indexY (nrows visitMatrix) (ncols visitMatrix) && visitMatrix ! (indexX, indexY) == distance 
                    = (indexX, indexY)
        | otherwise = previousTileInPathInDir currentX currentY distance visitMatrix (n-1)
        where
            (xDir, yDir) = getDirection n
            indexX = currentX + xDir
            indexY = currentY + yDir

--Move robot towards closest playpen so he can leave a baby
findPlaypen :: Int -> Int -> [Element] -> Element -> (Bool, [Element])-- Put baby down if playpen was reached
findPlaypen rows cols env robot | isElementVAtXY "Playpen" sourceX sourceY False env False = putBabyDown sourceX sourceY env
                                | x /= -1 =  (True, newEnv)
                                | otherwise = (False, env)
                    where
                        sourceX = row robot
                        sourceY = column robot
                        (coord, distance) = getNextStepToObjective rows cols robot "Playpen" ["Robot", "Obstacle", "Baby"] env 
                        (x, y) = coord
                        newEnv = reallocateRobot robot x y env 

--Modify the env as the robot leaves a baby in a given position
putBabyDown :: Int -> Int -> [Element] -> (Bool, [Element])
putBabyDown x y env = (True, finalEnv)
        where
            newEnv1 = removeElementFrom "Baby" x y True env True
            newEnv2 = removeElementFrom "Robot" x y True newEnv1 True
            baby = Baby x y False
            robot = Robot x y False
            finalEnv = newEnv2 ++ [baby] ++ [robot]

--Find closest activity to do between chase babies or dirt
stimateBestAnswer:: Int -> Int -> [Element] -> Element -> (Bool, [Element])
stimateBestAnswer rows cols env robot | x /= -1 = (True, newEnv)
                                      | otherwise = (False, env)
    where
        (bCoord, bDistance) = getNextStepToObjective rows cols robot "Baby" ["Robot", "Obstacle", "Playpen"] env 
        (dCoord, dDistance) = getNextStepToObjective rows cols robot "Dirt" ["Robot", "Obstacle", "Playpen"] env 
        (bX,bY) = bCoord--move robot towards closest baby 
        (dX,dY) = dCoord--move robot towards closest dirt
        (x,y) = if bX /= -1
                    then 
                        if dY /= -1
                            then 
                                if bDistance <= dDistance--comparing distances to find closest objective
                                    then (bX, bY)
                                    else (dX, dY)
                            else (bX,bY)
                    else (dX,dY)--at this point dX, dY can be -1 or not
        newEnv = reallocateRobot robot x y env


-------------------------------------------------Agent 2-------------------------------------------------------------------

--Proactive agent-> objective: capture babies
moveC3PO :: Int -> Int -> [Element] -> Element -> ( Bool, [Element])
moveC3PO rows cols env robot 
                  | wChild && length (freeBabies) == 0 && findDirtResult = (findDirtResult, findDirtEnv)
                  | wChild && (length (freeBabies) > 0 || length (dirt) == 0 )  && findPlaypenResult = (findPlaypenResult, findPlaypenEnv)
                  | not wChild && findBabyResult = (findBabyResult, findBabyEnv)
                  | uponDirt env robot && cleanResult = (cleanResult, cleanEnv)
                  | otherwise = (findDirtResult, findDirtEnv)--findDirt
                  where
                      wChild = wcompany robot
                      freeBabies = takeBabies env env
                      dirt = takeDirt env env
                      (findDirtResult, findDirtEnv) = findDirt rows cols env robot 
                      (findPlaypenResult, findPlaypenEnv) = findPlaypen rows cols env robot 
                      (findBabyResult, findBabyEnv) = findBaby rows cols env robot 
                      (cleanResult, cleanEnv) = cleanDirt env robot

--Stimate distance to closest baby and move towards it
--Returns a tuple with a boolean indicating if the robot could find the objective and the environment (modified accordingly if the move was ejected)
findBaby :: Int -> Int -> [Element] -> Element -> (Bool, [Element])
findBaby rows cols env robot | x /= -1 =  (True, newEnv)
                             | otherwise = (False, env)
                    where
                        (coord, distance) = getNextStepToObjective rows cols robot "Baby" ["Robot", "Obstacle", "Playpen"] env  
                        (x, y) = coord
                        newEnv = reallocateRobot robot x y env 
       

--Si tiene un ninno a 2 o menos pasos de distancia (y no carga otro) acercarse (aunque este sobre suciedad)
--Como es mas fino solo persigue a los ninnos, no limpia