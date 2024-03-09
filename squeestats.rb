input SqueezeType = { Low, default Mid, High, All};
input LongShortDefinition = { default HistAboveBelowZero, HistRisingFalling};

def nBB = 2.0; 
def Length = 20.0; 
def nK_High = 1.0; 
def nK_Mid = 1.5;
def nK_Low = 2.0;  
def price = close;

def selectedNK = if SqueezeType == SqueezeType.Mid then nK_Mid else if SqueezeType == SqueezeType.Low then nK_Low else if SqueezeType == SqueezeType.High then nK_High else nK_Mid;

def inSqueeze = TTM_Squeeze(price =  price, length = Length, nk = selectedNK, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentum = TTM_Squeeze(price =  price, length = Length, nk = selectedNK, nBB = nBB );

def fired = !inSqueeze and inSqueeze[1];
def firedLong = fired and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentum > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentum > squeezeMomentum[1]));

def squeezeCount = TotalSum(fired);

def inSqueezeLow = TTM_Squeeze(price =  price, length = Length, nk = nK_Low, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumLow = TTM_Squeeze(price =  price, length = Length, nk = nK_Low, nBB = nBB );

def firedLow = !inSqueezeLow and inSqueezeLow[1];

def firedLongLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumLow > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumLow > squeezeMomentumLow[1]));

def squeezeCountLow = TotalSum(firedLow);


def inSqueezeHigh = TTM_Squeeze(price =  price, length = Length, nk = nK_High, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumHigh = TTM_Squeeze(price =  price, length = Length, nk = nK_High, nBB = nBB );

def firedHigh = !inSqueezeHigh and inSqueezeHigh[1];
def firedLongHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumHigh > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumHigh > squeezeMomentumHigh[1]));

def squeezeCountHigh = TotalSum(firedHigh);


def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.5, "length" = 20.0)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 2.0, "length" = 20.0)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.0, "length" = 20.0)."Upper_Band";

def tSumFiredLow = TotalSum(firedLow);
def tSumFiredMid = TotalSum(fired);
def tSumFiredHigh = TotalSum(firedHigh);

AddLabel( BolKelDelta_Low <= 0,"Low "+tSumFiredLow+" ("+(firedLongLow/tSumFiredLow)+")");
AddLabel( BolKelDelta_Mid <= 0,"Mid "+tSumFiredMid+" ("+(firedLong/tSumFiredMid)+")");
#these 2 below break it
AddLabel( BolKelDelta_High <= 0,"High "+tSumFiredHigh+" ("+(firedLongHigh/tSumFiredHigh)+")");
AddLabel( !(BolKelDelta_Low <= 0) and !(BolKelDelta_Mid <= 0) and !(BolKelDelta_High <= 0), "None");
