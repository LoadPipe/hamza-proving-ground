import { HttpService } from '@nestjs/axios';
import { BadRequestException, HttpServer, Injectable } from '@nestjs/common';

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
    }

    private async createPaymentAddress(): Promise<string> {
        return ' ';
    }

    private async createSmartAccount(
        username: string,
        paymentAddress: string
    ): Promise<{
        paymentAddress: string;
        accountAddress: string;
        accountChainId: number;
    }> {
        return {
            paymentAddress: paymentAddress,
            accountAddress: '',
            accountChainId: 0,
        };
    }
}
