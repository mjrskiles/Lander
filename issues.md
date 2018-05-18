# Issues

## Features

## Bug fixes

### Physics

#### Unable to correct angular momentum

- When an angular force is applied to the space craft it is impossible to damp it without landing the craft. I.e. the craft keeps "pulling" in one direction indefinitely after the force is applied. One intuitively expects to be able to correct the roll velocity by firing the rocket in the other direction.
    - This may have to do with rocket nozzle currently applying only a linear force that runs directly through the center of the craft. Might need to implement thrust vectoring to fix this.