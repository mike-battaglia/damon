input LongShortDefinition = { default HistAboveBelowZero, HistRisingFalling};

def nBB = 2.0;
def Length = 20.0;
def nK_High = 1.0;
def nK_Mid = 1.5;
def nK_Low = 2.0;
def price = close;

def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_Mid, "length" = Length)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_Low, "length" = Length)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_High, "length" = Length)."Upper_Band";


def sqLow = BolKelDelta_Low <= 0;
def sqMid = BolKelDelta_Mid <= 0;
def sqHigh = BolKelDelta_High <= 0;

def selectedNK = if sqHigh then nK_High else if sqMid then nK_Mid else if sqLow then nK_Low else nK_Mid;

#def selectedNK = nK_Mid;

def inSqueeze = TTM_Squeeze(price =  price, length = Length, nk = selectedNK, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentum = TTM_Squeeze(price =  price, length = Length, nk = selectedNK, nBB = nBB );
def upMomentumStart = squeezeMomentum > squeezeMomentum[1] and squeezeMomentum[1] <= squeezeMomentum[2];
def downMomentumStart = squeezeMomentum < squeezeMomentum[1] and squeezeMomentum[1] >= squeezeMomentum[2];
def upMomentumLength = if upMomentumStart then 1 else if !downMomentumStart then upMomentumLength[1] + 1 else 0;
def completedUpMomentumLength = if downMomentumStart then upMomentumLength[1] else 0;
def downMomentumLength = if downMomentumStart then 1 else if !upMomentumStart then downMomentumLength[1] + 1 else 0;
def completedDownMomentumLength = if upMomentumStart then downMomentumLength[1] else 0;
def upCycles = TotalSum(upMomentumStart);
def downCycles = TotalSum(downMomentumStart);
def aveUpCycleLength = Round(TotalSum(completedUpMomentumLength) / upCycles, 0);
def aveDownCycleLength = Round(TotalSum(completedDownMomentumLength) / downCycles, 0);

def fired = !inSqueeze and inSqueeze[1];
def firedLong = fired and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentum > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentum > squeezeMomentum[1]));
def firedShort = fired and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentum <= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentum < squeezeMomentum[1]));

def squeezeCount = TotalSum(fired);

### ???
def theSqueezes = if TTM_Squeeze () .SqueezeAlert == 0 then 1 else 0;
def sumSqueezes = Sum(theSqueezes, 10);
def theSqueezeFired = if TTM_Squeeze () .SqueezeAlert[1] == 0 and TTM_Squeeze().SqueezeAlert == 1 then 1 else 0;
### ???

def sumFiredLong = TotalSum(firedLong);
def sumFiredShort = TotalSum(firedShort);
#def theRatio = (sumFiredLong/squeezeCount)*100;

  #disambiguate Sq state
AddLabel( sqLow, "Low " + squeezeCount + "=" + sumFiredLong + "+" + sumFiredShort + ", |" + sqLow + " " + sqMid + " " + sqHigh);
AddLabel( sqMid, "Mid " + squeezeCount + "=" + sumFiredLong + "+" + sumFiredShort + ", |" + sqLow + " " + sqMid + " " + sqHigh);
AddLabel( sqHigh, "High " + squeezeCount + "=" + sumFiredLong + "+" + sumFiredShort + ", |" + sqLow + " " + sqMid + " " + sqHigh);

#AssignBackgroundColor( if sqLow and !sqMid and !sqHigh then color.dark_green else if sqMid and !sqHigh then color.dark_red else if sqHigh then color.dark_orange else color.black);
