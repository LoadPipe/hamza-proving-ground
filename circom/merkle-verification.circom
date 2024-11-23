pragma circom 2.1.6;

include "./node_modules/circomlib/circuits/poseidon.circom";

template MerkleTreeVerification() {
    signal input leaf1; 
    signal input leaf2; 
    signal input root;

    signal output out;
    component poseidon = Poseidon(2);

    poseidon.inputs[0] <== leaf1;
    poseidon.inputs[1] <== leaf2;
    out <== poseidon.out;
}

component main = MerkleTreeVerification();