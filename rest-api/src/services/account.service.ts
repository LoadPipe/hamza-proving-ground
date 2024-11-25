import { HttpService } from '@nestjs/axios';
import { BadRequestException, HttpServer, Injectable } from '@nestjs/common';
import { ethers } from 'ethers';
import { accountIndexAbi } from 'src/abi';

const ACCOUNT_INDEX_ADDRESS = '0x28F4b3Cd33362B2879f98D4bB8e76112A3784C22';

@Injectable()
//TODO: rename
export class AccountService {
    constructor(private readonly httpService: HttpService) {}

    async createAccount(username: string): Promise<{
        paymentAddress: string;
        accountAddress: string;
        accountChainId: number;
    }> {
        //check the smart account index to see if the account (by username) already exists
        if (await this.userExists(username)) {
            //if it exists already, return an error
            throw new BadRequestException('Username already exists');
        }

        //create a payment address, save the private key
        const paymentAddress: string = await this.createPaymentAddress();

        //create an account on the smart contract
        return await this.createSmartAccount(username, paymentAddress);
    }

    async userExists(username: string): Promise<boolean> {
        return false;
        const contract = new ethers.Contract(
            ACCOUNT_INDEX_ADDRESS,
            accountIndexAbi
        );

        return await contract.accountExists(username);
    }

    private async createPaymentAddress(): Promise<string> {
        console.log('creating wallet');
        const wallet = ethers.Wallet.createRandom();
        console.log('created wallet', wallet.address);
        return wallet.address;
    }

    private async createSmartAccount(
        username: string,
        paymentAddress: string
    ): Promise<{
        paymentAddress: string;
        accountAddress: string;
        accountChainId: number;
    }> {
        console.log('creating provider', process.env.SEPOLIA_RPC_URL);
        const provider = new ethers.JsonRpcProvider(
            process.env.SEPOLIA_RPC_URL,
            11155111
        );
        console.log('getting signer', process.env.BUNDLER_PRIVATE_KEY);
        const signer = new ethers.Wallet(
            process.env.BUNDLER_PRIVATE_KEY ?? '',
            provider
        );

        console.log(signer.address);

        console.log('creating contract');
        const contract = new ethers.Contract(
            ACCOUNT_INDEX_ADDRESS,
            accountIndexAbi,
            signer
        );

        const id = ethers.keccak256(ethers.toUtf8Bytes(username));
        console.log('calling contract', id);
        const accountAddress = await contract.createAccount(
            id,
            ethers.ZeroAddress
        );

        return {
            paymentAddress: paymentAddress,
            accountAddress,
            accountChainId: 11155111,
        };
    }
}
