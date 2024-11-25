import { HttpService } from '@nestjs/axios';
import { HttpServer, Injectable } from '@nestjs/common';

@Injectable()
//TODO: rename
export class AccountService {
    constructor(private readonly httpService: HttpService) {}
}
