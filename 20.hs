import Data.List.Split (splitOn)
import Data.List (elemIndex, sortOn, groupBy)
import Data.Monoid ((<>))
import Data.Function (on)

data Vector3 s = Vector3 s s s deriving Eq

instance Functor Vector3 where
    fmap f (Vector3 x y z) = Vector3 (f x) (f y) (f z)

instance Num s => Semigroup (Vector3 s) where
    Vector3 x1 y1 z1 <> Vector3 x2 y2 z2 = Vector3 (x1 + x2) (y1 + y2) (z1 + z2)

instance Ord s => Ord (Vector3 s) where
    Vector3 x1 y1 z1 `compare` Vector3 x2 y2 z2 = compare x1 x2 <> compare y1 y2 <> compare z1 z2

type Property = Vector3 Double

data Particle = Particle {
    position     :: Property,
    velocity     :: Property,
    acceleration :: Property
}

(*|) :: Double -> Property -> Property
(*|) s = fmap (s *)

norm :: Property -> Double
norm (Vector3 x y z) = abs x + abs y + abs z

updateParticle :: Double -> Particle -> Particle
updateParticle t (Particle p v a) =
    Particle (p <> t *| v <> (t * (t + 1) / 2) *| a) (v <> t *| a) a

stepParticles :: [Particle] -> [Particle]
stepParticles particles =
    concat . filter ((== 1) . length) . groupBy ((==) `on` position) . sortOn position . map (updateParticle 1) $ particles

parseProperty :: String -> Property
parseProperty str = 
    let x : y : z : [] = map read . splitOn "," . drop 3 . init $ str
    in Vector3 x y z

parseLine :: String -> Particle
parseLine str =
    let p : v : a : [] = map parseProperty . splitOn ", " $ str
    in Particle p v a

main :: IO ()
main = do
    particles <- map parseLine . lines <$> readFile "20.txt"
    let distances = map (norm . position . updateParticle 400) particles
    print $ elemIndex (minimum distances) distances
    print $ length $ iterate stepParticles particles !! 40