template MerkleTreeVerification(depth) {
    signal input leaf; //product ID
    signal input root;
    signal input pathElements[depth]; //merke nodes for proof
    signal input pathIndex[depth];    //position of the leaf (0 or 1 at each level)

    signal output isValid; //1 if the proof is valid, 0 otherwise

    signal hash = leaf;

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

    isValid <== (hash === root);
}
