def inSqueezeLow = TTM_Squeeze(price = close, length = 20.0, nk = 2.0, nBB = 2.0 );
def squeezeMomentumLow = TTM_Squeeze(price = close, length = 20.0, nk = 2.0, nBB = 2.0 );
def firedLow = !inSqueezeLow and inSqueezeLow[1];
def firedLongLow = firedLow and (squeezeMomentumLow > 0);

def inSqueezeMid = TTM_Squeeze(price = close, length = 20.0, nk = 1.5, nBB = 2.0 );
def squeezeMomentumMid = TTM_Squeeze(price = close, length = 20.0, nk = 1.5, nBB = 2.0 );
def firedMid = !inSqueezeMid and inSqueezeMid[1];
def firedLongMid = firedMid and (squeezeMomentumMid > 0);

def inSqueezeHigh = TTM_Squeeze(price = close, length = 20.0, nk = 1.0, nBB = 2.0 );
def squeezeMomentumHigh = TTM_Squeeze(price = close, length = 20.0, nk = 1.0, nBB = 2.0 );
def firedHigh = !inSqueezeHigh and inSqueezeHigh[1];
def firedLongHigh = firedHigh and (squeezeMomentumHigh > 0);

def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.5, "length" = 20.0)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 2.0, "length" = 20.0)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.0, "length" = 20.0)."Upper_Band";

def sLow = BolKelDelta_Low <= 0;
def sMid = BolKelDelta_Mid <= 0;
def sHigh = BolKelDelta_High <= 0;

def tSumFiredLow = TotalSum(firedLow);
def tSumFiredMid = TotalSum(firedMid);
def tSumFiredHigh = TotalSum(firedHigh);

AddLabel( sLow,"Low "+tSumFiredLow+" ("+(firedLongLow/tSumFiredLow)+")");
AddLabel( sMid,"Mid "+tSumFiredMid+" ("+(firedLongMid/tSumFiredMid)+")");
AddLabel( sHigh,"High "+tSumFiredHigh+" ("+(firedLongHigh/tSumFiredHigh)+")");
#AddLabel( !sLow and !sMid and !sHigh, "None");
