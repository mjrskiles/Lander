# Issues

## Features

## Bug fixes

### Physics

#### Unable to correct angular momentum

- When an angular force is applied to the space craft it is impossible to damp it without landing the craft. I.e. the craft keeps "pulling" in one direction indefinitely after the force is applied. One intuitively expects to be able to correct the roll velocity by firing the rocket in the other direction.
    - This may have to do with rocket nozzle currently applying only a linear force that runs directly through the center of the craft. Might need to implement thrust vectoring to fix this.

## Design problems to solve

### What does the GameScene class do?

- Manages the node hierarchy
- has lifecycle callbacks for the game loop

#### How much game logic should reside in the GameScene class?

- As little as possible!
    - Use a scene delegate to manage game logic via lifecycle callbacks
    - Build craft/level data from JSON files
        - Craft files are higher priority

### Who gets input??

- Right now touch input is handled in the GameScene
- Core Motion input may be required to be handled by the ViewController?
    - At least by a class that can become the first responder
- One thing I would like to do is abstract away input from the Game/View Controller logic
    - Maybe some type of Input Adapter class?
        - Defines a standard interface for getting input and sending it to the game.
        - This would be desirable because I want to have the option of motion OR touch controls