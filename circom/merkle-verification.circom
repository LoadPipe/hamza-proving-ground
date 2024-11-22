pragma circom 2.1.6;

template MerkleTreeVerification(depth) {
    signal input leaf; 
    signal input root;
    signal input pathElements[depth]; 
    signal input pathIndex[depth]; 

    signal output isValid;

    signal hash <== leaf;

    for (var i = 0; i < depth; i++) {
        signal left;
        signal right;

        if (pathIndex[i] == 0) {
            left <== hash;
            right <== pathElements[i];
        } else {
            left <== pathElements[i];
            right <== hash;
        }

        hash <== Poseidon([left, right]);
    }

    isValid <== (hash == root);
}

component main = MerkleTreeVerification(3);