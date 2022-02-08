module Main where
import Random
import Env
import EnvChanges
import Agents
import Data.Matrix
import GameFlow

main :: IO ()
main = do
  let rows = 5
  let cols = 5
  let obsts = 2
  let robots = 2
  let babys = 2
  let dirt = 2
  let robotTypes = 1
  let randomVariationTime = 4
  let maxSimTime = 10
  startSimulation rows cols obsts robots babys dirt robotTypes randomVariationTime maxSimTime
 