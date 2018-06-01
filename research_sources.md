# Information Sources

## About Apollo

### LM Info

- Mass (total): 15,200 - 16,400 kg (with rover)
- Mass:
    - Descent stage: 
        - gross: 10,334 kg
        - dry: 2,134 kg (approx.)
    - Ascent stage: 
        - gross: 4,700 kg
        - dry: 2,150 kg
- Descent Propulsion System (DPS -- The rocket)
    - mass: 179 kg
    - fuel mass: 8,200 kg
    - thrust: 45,040 N
        - Throttlable between 10 and 60%
    - Specific impulse: 311 s
    - Delta V: 2,500 m/s
- orbit for CSM/LM
    - 15 km periapsis for the LM injection

https://en.wikipedia.org/wiki/Apollo_Lunar_Module

https://en.wikipedia.org/wiki/Descent_Propulsion_System

Moon Lander by Tom Kelly

https://www.nasa.gov/mission_pages/apollo/missions/apollo11.html

### The Moon

- Mean radius: 1,737 km
- Mass: 7.342x10^22 kg

## About SpriteKit



## About Physics

### How this app deals with gravity

We will assume a 15km altitude circular orbit for the injection burn. (This is about 1,752 km from the moon center)
- This requires an orbital velocity of ~1,672 m/s (according to Lisa, who is a jerk).
- v=sqrt((GM)/r) to find the velocity required for a circular orbit with radius r

One of the most important considerations to make in this game are the physics related to gravity. Although SpriteKit provides much of the physics functionality out of the box, there are a few important things to note. 

- First, although the acceleration of the 'world gravity' can be set in the scene's SKPhysicsWorld object, the acceleration is applied uniformly regardless of distance between bodies. In fact, There is no concept of the physics world's center in SpriteKit.

- Second, there is no concept of a circular world within SpriteKit. The simulation takes place on a 2D plane.

By keeping in mind some simple formulas, we should be able to create a suitably believable simulation within the SpriteKit framework.

One of the biggest problems posed by the uniformity of gravity and flat world is how to put something in orbit. You can't simply give the Lander a starting position high in the sky and enough velocity to keep it in orbit. It would just fall out of the sky anyway, because the acceleration due to gravity is the same as at the surface.

Therefore, we need to compensate the SKPhysicsWorld's dy setting based on the altitude of the craft. Using Newton's law of universal gravitation, we can calculate a suitable force.

`F = G((m1*m2) / r^2)`

Where G is the gravitational constant `6.674×10^−11 m^3⋅kg^−1⋅s^−2`, m1 and m2 are the masses of the objects, and r is the distance between their centers.

Once we have F, we can use the equation `F = ma` to determine the acceleration that should be applied to the spacecraft by `a = F/m`. This could be updated every frame, but it might make more sense to update it periodically in 'zones' to avoid unnecessary calculations.