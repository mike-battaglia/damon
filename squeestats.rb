input LongShortDefinition = { default HistAboveBelowZero, HistRisingFalling};

def nBB = 2.0; 
def Length = 20.0; 
def nK_High = 1.0; 
def nK_Mid = 1.5;
def nK_Low = 2.0;  
def price = close;

def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.5, "length" = 20.0)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 2.0, "length" = 20.0)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = 2.0, "length" = 20.0 )."upperband" - KeltnerChannels("factor" = 1.0, "length" = 20.0)."Upper_Band";

def sqLow = BolKelDelta_Low <= 0;
def sqMid = BolKelDelta_Mid <= 0;
def sqHigh = BolKelDelta_High <= 0;

def selectedNK = if sqMid then nK_Mid else if sqLow then nK_Low else if sqHigh then nK_High else nK_Mid;

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
def postSqueezeRun = if fired then 1 else if inSqueeze or downMomentumStart or upMomentumStart then 0 else postSqueezeRun[1];
def postSqueezeRunLength = if postSqueezeRun and !(downMomentumStart or upMomentumStart) then postSqueezeRunLength[1] + 1 else 0;
def completedPostSqueezeRun = if !postSqueezeRun and postSqueezeRun[1] then postSqueezeRunLength[1] else 0;
def postSqueezeRuns =  if !postSqueezeRun and postSqueezeRun[1] then 1 else 0;
def avePostSqueezeRun = TotalSum(completedPostSqueezeRun) / TotalSum(fired);
def priceFired = if fired then close[1] else priceFired[1];
def completedPriceMovePercent =  if !postSqueezeRun and postSqueezeRun[1] then AbsValue(100 * (close[1] - priceFired[1]) / priceFired[1]) else 0;
def avePostSqueezePercent = TotalSum(completedPriceMovePercent) / TotalSum(fired);

def squeezeLength = if inSqueeze then squeezeLength[1] + 1 else 0;
def completedSqueezeLength = if fired then squeezeLength[1] else 0;
def squeezeCount = TotalSum(fired);
def aveSqueezeLength = Round(TotalSum(completedSqueezeLength) / squeezeCount, 0);

def theRatio = firedLong/squeezeCount;

AddLabel( sqLow,"Low, Count="+squeezeCount+", Long="+firedLong+", Short="+firedShort);
AddLabel( sqMid,"Mid, Count="+squeezeCount+", Long="+firedLong+", Short="+firedShort);
AddLabel( sqHigh,"High, Count="+squeezeCount+", Long="+firedLong+", Short="+firedShort);
AddLabel( !(sqLow) and !(sqMid) and !(sqHigh), "None");

AssignBackgroundColor( if sqLow and !sqMid and !sqHigh then color.dark_green else if sqMid and !sqHigh then color.dark_red else if sqHigh then color.dark_orange else color.black);
