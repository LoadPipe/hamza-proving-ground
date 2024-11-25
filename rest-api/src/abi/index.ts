export const accountIndexAbi = [
    {
        type: 'function',
        name: 'accountExists',
        inputs: [{ name: 'addr', type: 'address', internalType: 'address' }],
        outputs: [{ name: '', type: 'bool', internalType: 'bool' }],
        stateMutability: 'view',
    },
    {
        type: 'function',
        name: 'createAccount',
        inputs: [
            { name: 'id', type: 'bytes32', internalType: 'bytes32' },
            { name: 'userEoa', type: 'address', internalType: 'address' },
        ],
        outputs: [],
        stateMutability: 'nonpayable',
    },
    {
        type: 'event',
        name: 'AccountCreated',
        inputs: [
            {
                name: 'accountAddress',
                type: 'address',
                indexed: true,
                internalType: 'address',
            },
        ],
        anonymous: false,
    },
];

export const smartAccountAbi = [
    {
        type: 'constructor',
        inputs: [
            { name: '_bundler', type: 'address', internalType: 'address' },
            { name: '_id', type: 'bytes32', internalType: 'bytes32' },
            { name: '_userEoa', type: 'address', internalType: 'address' },
        ],
        stateMutability: 'nonpayable',
    },
    {
        type: 'function',
        name: 'withdrawFunds',
        inputs: [
            { name: 'amount', type: 'uint256', internalType: 'uint256' },
            { name: 'tokenAddress', type: 'address', internalType: 'address' },
        ],
        outputs: [],
        stateMutability: 'nonpayable',
    },
];
