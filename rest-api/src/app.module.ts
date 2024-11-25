import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoinGeckoService } from './coin-gecko.service';
import { HttpModule } from '@nestjs/axios';
import { CoinGeckoController } from './coin-gecko.controller';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';

@Module({
    imports: [HttpModule],
    controllers: [AppController, CoinGeckoController, AccountController],
    providers: [AppService, CoinGeckoService, AccountService],
})
export class AppModule {}
