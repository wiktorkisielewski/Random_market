#include <Trade\Trade.mqh>
input int StopLoss=350;
input double lot=0.1;

bool cantrade=true;  
double Ask;          
double Bid; 
double last_profit = 0;
double pos_size = 0.1;

CTrade trade;

int OpenLong(double volume= 0.1,
             int slippage=1,
             string comment="LONG IT",
             int magic=0)

  {
   MqlTradeRequest long_trade;
   ZeroMemory(long_trade);
   MqlTradeResult long_trade_result;

   long_trade.action=TRADE_ACTION_DEAL;
   long_trade.symbol=Symbol();
   long_trade.volume=NormalizeDouble(volume,1);
   long_trade.price=NormalizeDouble(Ask,_Digits);
   long_trade.sl=NormalizeDouble(Ask-StopLoss*_Point,_Digits);
   long_trade.tp=0;
   long_trade.deviation=slippage;
   long_trade.type=ORDER_TYPE_BUY;
   long_trade.type_filling=ORDER_FILLING_IOC;
   long_trade.comment=comment;
   long_trade.magic=magic;

   ResetLastError();

   if(OrderSend(long_trade,long_trade_result))
     {
      Print("Operation result code - ",long_trade_result.retcode);
     }else{
      Print("Operation result code - ",long_trade_result.retcode);
      Print("Error in request = ",GetLastError());
     }
   return(0);
  }

int OpenShort(double volume=0.1,
              int slippage=1,
              string comment="SHORT IT",
              int magic=0)
  {
   MqlTradeRequest short_trade;
   MqlTradeResult short_trade_result;
   ZeroMemory(short_trade);

   short_trade.action=TRADE_ACTION_DEAL;
   short_trade.symbol=Symbol();
   short_trade.volume=NormalizeDouble(volume,1);
   short_trade.price=NormalizeDouble(Bid,_Digits);
   short_trade.sl=NormalizeDouble(Bid+StopLoss*_Point,_Digits);
   short_trade.tp=0;
   short_trade.deviation=slippage;
   short_trade.type=ORDER_TYPE_SELL;
   short_trade.type_filling=ORDER_FILLING_IOC;
   short_trade.comment=comment;
   short_trade.magic=magic;

   ResetLastError();

   if(OrderSend(short_trade,short_trade_result))
     {
      Print("Operation result code - ",short_trade_result.retcode);
     }else {
      Print("Operation result code - ",short_trade_result.retcode);
      Print("Error in request = ",GetLastError());
     }
   return(0);
  }

int OnInit() {
   return(0);
  }

void OnDeinit(const int reason){}


void OnTick() {
   MqlDateTime mqldt;
   TimeCurrent(mqldt);

   double direction;

   if((MathMod(MathRand(),2)==0)){
    direction = 1;
   } else {
   direction = 0;
   }


   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   Ask=last_tick.ask;
   Bid=last_tick.bid;

cantrade=true;

   if(!PositionSelect(_Symbol)) {
     HistorySelect(0,TimeCurrent()); 
         uint     total = HistoryDealsTotal(); 
         ulong    ticket = 0; 
      for(uint i=0;i<total;i++) { 
         if((ticket=HistoryDealGetTicket(i))>0) 
            {
            last_profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);  
            Print(last_profit);
            } 
     } 

     if (last_profit >= 0) {
         Sleep(3600000 * 6);
         if (direction == 0) {
            OpenShort(lot,5,"SHORT IT",1234);
            direction = 1;
         } else {
            OpenLong(lot,5,"LONG IT",1234);
            direction = 0;
         }
      }
      else {
         Sleep(360000 * 1/40);
         if (direction == 0) {
            OpenShort(lot,5,"SHORT IT",1234);
            direction = 1;
         } else {
            OpenLong(lot,5,"LONG IT",1234);
            direction = 0;
         }
      }
     }

    if(PositionsTotal() == 1){
      if(PositionSelect(_Symbol) == true) {
         ENUM_POSITION_TYPE  type;
         double open_price;
         double current_stop;
         ulong ticket;

         type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         current_stop = PositionGetDouble(POSITION_SL);
         ticket = PositionGetInteger(POSITION_TICKET);

         if(type == POSITION_TYPE_BUY)
            {
              if (Bid > open_price) {
                  double NewLongSL = NormalizeDouble(Bid - StopLoss*_Point, _Digits);
                  if (NewLongSL > current_stop) {
                     trade.PositionModify(ticket, NewLongSL, 0);
                  }else {
                     Print("nope");
                  }
              }     
            }
          if(type == POSITION_TYPE_SELL)
            {
              if (Ask < open_price) {
                  double NewShortSL = NormalizeDouble(Ask + StopLoss*_Point, _Digits);
                  if (NewShortSL < current_stop) {
                     trade.PositionModify(ticket, NewShortSL, 0);
                  }else {
                     Print("nope");
                  }
              }     
            }
      }
   }
   return;
}