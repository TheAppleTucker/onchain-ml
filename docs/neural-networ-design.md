# Yo

Really annoying that OOP is not really a thing in solidity. Sui is the future perhaps.

## Spec for Neural Network

    Model Class:
        mapping(uint => int128[][] memory)) layers
        - maps weight name to the associated weight matrix
            - layers maps 'w0' to weight matrix 0 shape m1 by n1
            - layers maps 'b0' to bias matrix 0 shape n1
            - layers also store cached matrices for backprop
        
        layerForward(int128[][] x, uint i, bool isTraining, string memory layerType)
            - implements the logic to do a forward pass
            - if isTraining is true, caches matrices for backpropogation, freezes weights and only computes output
            - layerType right now is only fully connected. Might spice it up with some convolutional layers?!?!

        layerBackward(int128[][] out, uint i, bool isTraining, string memory layerType)
            - if not isTraining, then simply returns the gradient with respect to input
