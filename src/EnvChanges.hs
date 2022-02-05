module EnvChanges where
import Env 
import Random

-------------------------------------------------Babie's moves---------------------------------------------------

--Takes an envrionment end return a list with the free babies found on it
takeBabies :: [Element] -> [Element] -> [Element]
takeBabies [] env = []  
takeBabies (Baby x y c:rest) env | not ( inPlayPen (Baby x y c) env ) = [Baby x y c] ++ takeBabies rest env
                             | otherwise =  takeBabies rest env
takeBabies (e:rest) env = takeBabies rest env

inPlayPen :: Element -> [Element] -> Bool
inPlayPen (Baby x y w) [] = False
inPlayPen (Baby x y w) (Playpen ex ey:rest) | ex == x && ey == y = True
                                | otherwise = inPlayPen (Baby x y w) rest
inPlayPen (Baby x y w) (e:rest) = inPlayPen (Baby x y w) rest

--Returns a new environment where all babies have moved to an adyacent position (or have decided to stay in the previous one)
moveBabies :: Int -> Int -> [Element] -> [Element]
moveBabies rows cols env = newEnv
                where
                    babiesPos = takeBabies env env
                    newEnv = moveBabiesAux rows cols env babiesPos

--Moves all babies in the list provided
moveBabiesAux :: Int -> Int -> [Element] -> [Element] -> [Element]
moveBabiesAux rows cols env [] = env 
moveBabiesAux rows cols env (baby:rest) = finalEnv
                                where
                                    newEnv = tryMoveBaby rows cols env baby 
                                    finalEnv = moveBabiesAux rows cols newEnv rest

--Takes in an environment and try to move a given baby
tryMoveBaby :: Int -> Int -> [Element] -> Element -> [Element] 
tryMoveBaby rows cols env baby = if not (wcompany baby) then finalEnv else env    
                        where
                            x = row baby
                            y = column baby
                            randDir = myRandom 5
                            (xdir, ydir) = getDirection randDir
                            (nextx, nexty) = nextValidPos x y xdir ydir rows cols env
                            finalEnv = reorganizeRoom x y xdir ydir nextx nexty env

--Move baby one position and obstacles if neccessary
reorganizeRoom :: Int -> Int -> Int -> Int -> Int -> Int -> [Element] -> [Element]
reorganizeRoom x y xdir ydir nextx nexty env 
            | x == nextx && y == nexty = env
            | nextx /= -1 && nexty /= -1 = finalEnv
            | otherwise = env
                where
                    adyx = x + xdir
                    adyy = y + ydir
                    newEnv = if nextx /= adyx || nexty /= adyy 
                                then reallocateObstacleFromTo adyx adyy nextx nexty env
                                else env 
                    finalEnv = reallocateBabyFromTo x y adyx adyy newEnv


--Check for the first free position following a given direction ( is a line of obstacles is found jump)
nextValidPos :: Int -> Int -> Int -> Int -> Int -> Int -> [Element] -> (Int, Int)
nextValidPos x y xdir ydir rows cols env | withinBounds nextx nexty rows cols && freePos nextx nexty env = (nextx, nexty) 
                               | withinBounds nextx nexty rows cols && obstaclePresent nextx nexty env = nextValidPos nextx nexty xdir ydir rows cols env
                               | otherwise = (-1, -1)
                                  where 
                                      nextx = x + xdir
                                      nexty = y + ydir

--Check wheter or not there is an obstacle place in coordinates x, y
obstaclePresent :: Int -> Int -> [Element] -> Bool
obstaclePresent x y [] = False 
obstaclePresent x y (Obstacle or oc:rest) = if or == x && oc == y 
                                            then True
                                            else obstaclePresent x y rest  
obstaclePresent x y (e:rest) = obstaclePresent x y rest 

--Reallocates an obstacle from a given postiion to another
reallocateObstacleFromTo :: Int -> Int -> Int -> Int -> [Element] -> [Element]
reallocateObstacleFromTo x y nextx nexty env = finalEnv
                                            where
                                                newEnv = removeElementAt x y env
                                                finalEnv = newEnv ++ [Obstacle nextx nexty]

--remove a given element form the environment
removeElementAt :: Int -> Int -> [Element] -> [Element]
removeElementAt x y [] = []
removeElementAt x y (e:rest) = if row e == x && column e == y 
                                then rest
                                else [e] ++ removeElementAt x y rest  

--reallocates a baby from a given position to another
reallocateBabyFromTo :: Int -> Int -> Int -> Int -> [Element] -> [Element]
reallocateBabyFromTo x y nextx nexty env = finalEnv
                                            where
                                                newEnv = removeElementAt x y env --is assumed no other element overlaps
                                                finalEnv = newEnv ++ [Baby nextx nexty False]

--returns one of 5 directions: none, rigth, down, left, up
getDirection :: Int -> (Int, Int)
getDirection n = case n of 0 -> (0,0)
                           1 -> (0,1)
                           2 -> (1,0)
                           3 -> (0,-1)
                           4 -> (-1,0)


-------------------------------------------------Dirt Creation---------------------------------------------------

-- createDirt :: Int -> [Element] 