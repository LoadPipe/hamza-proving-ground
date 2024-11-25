import { Module } from '@nestjs/common';
import { AppController } from './controllers/app.controller';
import { AppService } from './services/app.service';
import { CoinGeckoService } from './services/coin-gecko.service';
import { HttpModule } from '@nestjs/axios';
import { CoinGeckoController } from './controllers/coin-gecko.controller';
import { AccountController } from './controllers/account.controller';
import { AccountService } from './services/account.service';

@Module({
    imports: [HttpModule],
    controllers: [AppController, CoinGeckoController, AccountController],
    providers: [AppService, CoinGeckoService, AccountService],
})
export class AppModule {}
