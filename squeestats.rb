input SqueezeType = { Low, default Mid, High, All};
input LongShortDefinition = { default HistAboveBelowZero, HistRisingFalling};

def nBB = 2.0; 
def Length = 20.0; 
def nK_High = 1.0; 
def nK_Mid = 1.5;
def nK_Low = 2.0;  
def price = close;
def selectedNK = if SqueezeType == SqueezeType.Mid then nK_Mid else if SqueezeType == SqueezeType.Low then nK_Low else if SqueezeType == SqueezeType.High then nK_High else nK_Mid;

def inSqueezeLow = TTM_Squeeze(price =  price, length = Length, nk = nK_Low, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumLow = TTM_Squeeze(price =  price, length = Length, nk = nK_Low, nBB = nBB );
def firedLow = !inSqueezeLow and inSqueezeLow[1];
def firedLongLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumLow > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumLow > squeezeMomentumLow[1]));
def firedShortLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumLow <= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumLow < squeezeMomentumLow[1]));
def squeezeCountLow = TotalSum(firedLow);

def inSqueezeMid = TTM_Squeeze(price =  price, length = Length, nk = selectedNK, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumMid = TTM_Squeeze(price =  price, length = Length, nk = selectedNK, nBB = nBB );
def firedMid = !inSqueezeMid and inSqueezeMid[1];
def firedLongMid = firedMid and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumMid > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumMid > squeezeMomentumMid[1]));
def firedShortMid = firedMid and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumMid <= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumMid < squeezeMomentumMid[1]));
def squeezeCountMid = TotalSum(firedMid);

def inSqueezeHigh = TTM_Squeeze(price =  price, length = Length, nk = nK_High, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumHigh = TTM_Squeeze(price =  price, length = Length, nk = nK_High, nBB = nBB );
def firedHigh = !inSqueezeHigh and inSqueezeHigh[1];
def firedLongHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumHigh > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumHigh > squeezeMomentumHigh[1]));
def firedShortHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumHigh <= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumHigh < squeezeMomentumHigh[1]));
def squeezeCountHigh = TotalSum(firedHigh);

# Mike's cooking begins here
### Damon said he wants "Long divided by Count"
def longOverCountLow = totalSum(firedLongLow)/totalSum(firedLow);

def longOverCountMid = totalSum(firedLongMid)/totalSum(firedMid);

def longOverCountHigh = totalSum(firedLongHigh)/totalSum(firedHigh);

### Then average those together
def longOverCountAvg = Round(((longOverCountLow+longoverCountMid+longoverCountHigh)/3)*100,0);

def nanCheck;

if (!isNaN(longOverCountAvg)) {
    nanCheck = 1;
} else {
    nanCheck = 0;
}

### Plot below or AddLabel
# plot thePlot = foo;

AddLabel(nanCheck, "L/C = "+longOverCountAvg+"%", color.WHITE);
AddLabel(!nanCheck, "Can't div/0", color.GRAY);

AssignBackgroundColor (if (nanCheck) then Color.BLACK else Color.BLACK);

### Example for reference below
# def rock = 0;
# def scissors = 0;
# def win = rock > scissors;

# AddLabel(yes, if win then "ROCK WINS" else "SCISSORS RULE️", if win then color.BLUE else color.YELLOW);

# AssignBackgroundColor (if win then Color.GREEN else Color.RED);

#AddLabel( sLow,"Low "+sumShqueeze,color.white);
#AddLabel( sMid,"Mid "+sumShqueeze,color.white);
#AddLabel( sHigh,"High "+sumShqueeze,color.white);
#AddLabel( !sLow and !sMid and !sHigh, "None");
#AssignBackgroundColor( if sLow and !sMid and !sHigh then color.dark_green else if sMid and !sHigh then color.dark_red else if sHigh then color.dark_orange else color.black);
