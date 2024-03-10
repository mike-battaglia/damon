input LongShortDefinition = { default HistAboveBelowZero, HistRisingFalling};

def nBB = 2.0;
def Length = 20.0;
def nK_High = 1.0;
def nK_Mid = 1.5;
def nK_Low = 2.0;
def price = close;

###
### START CONTROL PANEL
### USE THIS SECTION TO ENABLE
### HIGM / MEDIUM / LOW
### AND DARK COLORS
###

# Only enable one of the selectedNK below.
#def selectedNK = nK_Low;
def selectedNK = nK_Mid;
#def selectedNK = nK_High; 

# set darkColors to 1 for Dark Mode, 0 for Light Mode.
#def darkColors = 0;
def darkColors = 1;

###
### END CONTROL PANEL
###


def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_Mid, "length" = Length)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_Low, "length" = Length)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_High, "length" = Length)."Upper_Band";


def bbLow = BolKelDelta_Low <= 0;
def bbMid = BolKelDelta_Mid <= 0;
def bbHigh = BolKelDelta_High <= 0;

### This assigns a 1 to indicate the Compression, others get 0.
def sqHigh = if bbHigh then 1 else 0;
def sqMid = if (bbMid and !bbHigh) then 1 else 0;
def sqLow = if (bbLow and !bbMid) then 1 else 0;
###

#def selectedNK = if sqHigh then 1.0 else if sqMid then 1.5 else if sqLow then 2.0 else 1.5;
#def selectedNK = ((sqHigh)+(sqMid*1.5)+(sqLow*2.0));

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

def sumFiredLong = TotalSum(firedLong);
def sumFiredShort = TotalSum(firedShort);
def theRatio = Round((sumFiredLong/squeezeCount)*100,0);

plot results = 0;
results.AssignValueColor(if results then color.black else color.black);
### Colors:
#Dark red: (88, 0, 0)
#Medium red: (128, 0, 0)
#Dark green: (0, 88, 0)
#Medium green: (0, 128, 0)
#Dark orange: (128, 77, 0)
#Medium orange: (128, 99, 0)
#Dark blue: (0, 0, 88)
#Medium blue: (0, 0, 128)

AssignBackgroundColor(if sqLow and (selectedNK == nK_Low) then (if darkColors then CreateColor(0, 88, 0) else CreateColor(0, 128, 0)) else if sqMid and (selectedNK == nK_Mid) then (if darkColors then CreateColor(88, 0, 0) else CreateColor(175, 0, 0)) else if sqHigh and (selectedNK == nK_High) then (if darkColors then CreateColor(128, 77, 0) else CreateColor(220, 100, 0)) else color.black );

AddLabel( sqLow and (selectedNK == nK_Low), "" + squeezeCount + "   " + theRatio + "%", color.white);

AddLabel( sqMid and (selectedNK == nK_Mid), "" + squeezeCount + "   " + theRatio + "%", color.white);

AddLabel( sqHigh and (selectedNK == nK_High), "" + squeezeCount + "   " + theRatio + "%", color.white);
