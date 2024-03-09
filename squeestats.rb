def inSqueezeLow = TTM_Squeeze(price = close, length = 20.0, nk = 2.0, nBB = 2.0 );
def firedLow = !inSqueezeLow and inSqueezeLow[1];
def firedLongLow = firedLow and (inSqueezeLow > 0);

def inSqueezeMid = TTM_Squeeze(price = close, length = 20.0, nk = 1.5, nBB = 2.0 );
def firedMid = !inSqueezeMid and inSqueezeMid[1];
def firedLongMid = firedMid and (inSqueezeMid > 0);

def inSqueezeHigh = TTM_Squeeze(price = close, length = 20.0, nk = 1.0, nBB = 2.0 );
def firedHigh = !inSqueezeHigh and inSqueezeHigh[1];
def firedLongHigh = firedHigh and (inSqueezeHigh > 0);

def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.5, "length" = 20.0)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 2.0, "length" = 20.0)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.0, "length" = 20.0)."Upper_Band";

def tSumFiredLow = TotalSum(firedLow);
def tSumFiredMid = TotalSum(firedMid);
def tSumFiredHigh = TotalSum(firedHigh);

AddLabel( BolKelDelta_Low <= 0,"Low "+tSumFiredLow+" ("+(firedLongLow/tSumFiredLow)+")");
AddLabel( BolKelDelta_Mid <= 0,"Mid "+tSumFiredMid+" ("+(firedLongMid/tSumFiredMid)+")");
AddLabel( BolKelDelta_High <= 0,"High "+tSumFiredHigh+" ("+(firedLongHigh/tSumFiredHigh)+")");
#AddLabel( !sLow and !sMid and !sHigh, "None");
