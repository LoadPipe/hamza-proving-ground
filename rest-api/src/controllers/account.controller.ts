import {
    Controller,
    Get,
    Query,
    HttpException,
    HttpStatus,
} from '@nestjs/common';
import { AccountService } from '../services/account.service';

@Controller('account')
export class AccountController {
    constructor(private readonly accountService: AccountService) {}

    @Get('/create') // or @Get('/exch') depending on your setup
    async createAccount(@Query('username') username: string): Promise<{
        paymentAddress: string;
        accountAddress: string;
        accountChainId: number;
    }> {
        return await this.accountService.createAccount(username);
    }
}
