import {
    Controller,
    Get,
    Query,
    HttpException,
    HttpStatus,
} from '@nestjs/common';
import { AccountService } from './account.service';

@Controller('account')
export class AccountController {
    constructor(private readonly accountService: AccountService) {}
}
