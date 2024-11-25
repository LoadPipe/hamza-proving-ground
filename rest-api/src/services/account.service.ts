import { HttpService } from '@nestjs/axios';
import { HttpServer, Injectable } from '@nestjs/common';

@Injectable()
//TODO: rename
export class AccountService {
    constructor(private readonly httpService: HttpService) {}

    async createAccount(username: string): Promise<{
        paymentAddress: string;
        accountAddress: string;
        accountChainId: number;
    }> {
        //
        //check the smart account index to see if the account (by username) already exists
        //
        //if it exists already, return an error
        //
        //create a payment address, save the private key
        //
        //create an account on the smart contract
        //
        //return the payment address and smart account address

        return {
            paymentAddress: '',
            accountAddress: '',
            accountChainId: 0,
        };
    }
}
