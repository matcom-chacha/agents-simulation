module EnvChanges where
import Env 
import Random

-------------------------------------------------Babie's moves---------------------------------------------------

--Takes an envrionment end return a list with the free babies found on it 
--(free babies aka babies without company and not in playpens)
takeBabies :: [Element] -> [Element] -> [Element]
takeBabies [] env = []  
takeBabies (Baby x y c:rest) env | not ( inPlayPen (Baby x y c) env ) && not c = [Baby x y c] ++ takeBabies rest env
                             | otherwise =  takeBabies rest env
takeBabies (e:rest) env = takeBabies rest env

--Check wether the given postion contains a playpen or not
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
                            randDir = myRandom 0 4
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

--Takes in old environment and new one and return a final Env with the dirt that should have been generated by babies while moving
createDirt :: Int -> Int -> [Element] -> [Element] -> [Element] 
createDirt rows cols oldEnv newEnv = finalEnv
                            where
                                babies = takeBabies oldEnv oldEnv
                                finalEnv = createDirtAux rows cols babies babies oldEnv newEnv

--Note que se cuentan en una casilla los bebes no cargados ni en corral
createDirtAux :: Int -> Int -> [Element]-> [Element] -> [Element] -> [Element] -> [Element]
createDirtAux rows cols [] babies oldEnv newEnv = newEnv 
createDirtAux rows cols (Baby x y wc:rest) babies oldEnv newEnv =  createDirtAux rows cols rest babies oldEnv (babysDirt ++ newEnv)
                            where
                                gridPos = getGridPos rows cols x y
                                partners = getGridPartners babies gridPos--including itself
                                availablePos = getGridFreePos gridPos newEnv 
                                dirtToGenerate = getCorrespondingDirt partners
                                babysDirt = allocateNewDirt dirtToGenerate availablePos newEnv--get dirt generate by current baby

--Return an array with the coordinates of a grid centered in x, y
getGridPos :: Int -> Int -> Int -> Int -> [(Int, Int)]
getGridPos rows cols x y = getValidPos rows cols x y 0 0
                        ++ getValidPos rows cols x y (-1) (-1)
                        ++ getValidPos rows cols x y (-1) 0
                        ++ getValidPos rows cols x y (-1) 1
                        ++ getValidPos rows cols x y 0 (-1)
                        ++ getValidPos rows cols x y 0 1
                        ++ getValidPos rows cols x y 1 (-1)
                        ++ getValidPos rows cols x y 1 0
                        ++ getValidPos rows cols x y 1 1 


getValidPos :: Int -> Int-> Int -> Int -> Int -> Int -> [(Int, Int)]
getValidPos rows cols x y xdir ydir = gridPos
                                    where
                                        nextX = x + xdir
                                        nextY = y + ydir
                                        gridPos = 
                                            if withinBounds nextX nextY rows cols
                                                then [(nextX, nextY)]
                                                else []

--Return number of babies present in the grid positions provided
getGridPartners :: [Element] -> [(Int, Int)] -> Int 
getGridPartners [] gridPos= 0 
getGridPartners (e:rest) gridPos | matchCoordinates (row e) (column e) gridPos = 1 + getGridPartners rest gridPos
                                 | otherwise = getGridPartners rest gridPos


--Function to check wether an Element has a coordinate of a given set
matchCoordinates :: Int -> Int -> [(Int, Int)] -> Bool 
matchCoordinates x y [] = False 
matchCoordinates x y ((cx, cy):rest) | x == cx && y == cy = True
                                     | otherwise = matchCoordinates x y rest

--Return an array with the coordinates of the free positions in the newEnv in a grid centered at x y
getGridFreePos :: [(Int, Int)] -> [Element] -> [(Int, Int)]
getGridFreePos [] newEnv = []
getGridFreePos ((x, y):rest) newEnv | freePos x y newEnv = [(x,y)] ++ getGridFreePos rest newEnv
                                    | otherwise = getGridFreePos rest newEnv

--Return the amount of dirty tiles to generate by a baby if it has a given number of partners
getCorrespondingDirt :: Int -> Int
getCorrespondingDirt partners | partners == 1 = myRandom 0 1
                              | partners == 2 = myRandom 0 1--separated for clarity
                              | partners >= 3 = myRandom 0 2--every robot in the grid can generate up to 2 tiles of dirt

--Allocate tiles with dirt in env picking one of the available positions of a given grid
allocateNewDirt :: Int -> [(Int, Int)] -> [Element] -> [Element]
allocateNewDirt 0 availablePos env = []
allocateNewDirt dirtToGenerate [] env = []
allocateNewDirt dirtToGenerate availablePos env = newDirt ++ allocateNewDirt (dirtToGenerate - 1) newAvailablePos env
                        where
                            randIndex = myRandom 0 ((length availablePos)-1) 
                            (dx, dy) = availablePos !! randIndex
                            newDirt = [Dirt dx dy]
                            newAvailablePos = removeNthElement randIndex availablePos

--Remove nth element of an array
removeNthElement :: Int -> [(Int, Int)] -> [(Int, Int)] 
removeNthElement 0 (e: rest) = rest 
removeNthElement index (e: rest) = [e] ++ removeNthElement (index - 1) rest
