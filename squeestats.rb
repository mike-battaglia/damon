# ST_SqueezePRO_Stats
# (c) 2019 Simpler Trading, LLC
# Revision 05/17/19

# *** Sharing of this source code is expressly prohibited by the terms of your user agreement ***

input SqueezeType = { Low, default Mid, High, All};
input LongShortDefinition = { default HistAboveBelowZero, HistRisingFalling};

def nBB = 2.0; 
def Length = 20.0; 
def nK_High = 1.0; 
def nK_Mid = 1.5;
def nK_Low = 2.0;  
def price = close;

DefineGlobalColor("SqueezeStats", color.white);
DefineGlobalColor("CurrentSqueeze", color.yellow);
DefineGlobalColor("RisingHistogramStats", color.cyan);
DefineGlobalColor("FallingHistogramStats", color.red);
DefineGlobalColor("PostSqueezeStats", color.orange);

DefineGlobalColor("Low", color.light_gray);
DefineGlobalColor("Mid", color.pink);
DefineGlobalColor("High", color.orange);

def selectedNK = if SqueezeType == SqueezeType.Mid then nK_Mid else if SqueezeType == SqueezeType.Low then nK_Low else if SqueezeType == SqueezeType.High then nK_High else nK_Mid;

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

AddLabel(SqueezeType != SqueezeType.All, if SqueezeType == SqueezeType.Mid then "MID" else if SqueezeType == SqueezeType.Low then "LOW" else "HIGH", if SqueezeType == SqueezeType.Mid then color.red else if SqueezeType == SqueezeType.Low then color.black else color.DARK_ORANGE);
AddLabel(SqueezeType != SqueezeType.All, "Squeeze Count: " + squeezeCount, GlobalColor("SqueezeStats"));
AddLabel(SqueezeType != SqueezeType.All, "Fired Long: " + totalSum(firedLong), GlobalColor("SqueezeStats"));
AddLabel(SqueezeType != SqueezeType.All, "Fired Short: " + totalSum(firedShort), GlobalColor("SqueezeStats"));

AddLabel(SqueezeType != SqueezeType.All, "Ave Squeeze Length: " + aveSqueezeLength, GlobalColor("SqueezeStats"));
AddLabel(inSqueeze, "Current Squeeze: " + squeezeLength, GlobalColor("CurrentSqueeze"));
AddLabel(SqueezeType != SqueezeType.All, "Ave Rising Hist: " + aveUpCycleLength, GlobalColor("RisingHistogramStats"));
AddLabel(SqueezeType != SqueezeType.All, "Ave Falling Hist: " + aveDownCycleLength, GlobalColor("FallingHistogramStats"));
AddLabel(SqueezeType != SqueezeType.All, "Ave Post Squeeze Run: " + Round(avePostSqueezeRun, 0), GlobalColor("PostSqueezeStats"));
AddLabel(SqueezeType != SqueezeType.All, "Longest Post Squeeze Run: " + HighestAll(completedPostSqueezeRun), GlobalColor("PostSqueezeStats"));
AddLabel(SqueezeType != SqueezeType.All, "Ave Post Squeeze Move: " + Round(avePostSqueezePercent, 2) + "% = $" + Round(avePostSqueezePercent * (close / 100), 2), GlobalColor("PostSqueezeStats"));
AddLabel(SqueezeType != SqueezeType.All, "Biggest Post Squeeze Move: " + Round(HighestAll(completedPriceMovePercent) , 2) + "% = $" + Round(HighestAll(completedPriceMovePercent) * (close / 100), 2), GlobalColor("PostSqueezeStats"));

def inSqueezeLow = TTM_Squeeze(price =  price, length = Length, nk = nK_Low, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumLow = TTM_Squeeze(price =  price, length = Length, nk = nK_Low, nBB = nBB );
def upMomentumStartLow = squeezeMomentumLow > squeezeMomentumLow[1] and squeezeMomentumLow[1] <= squeezeMomentumLow[2];
def downMomentumStartLow = squeezeMomentumLow < squeezeMomentumLow[1] and squeezeMomentumLow[1] >= squeezeMomentumLow[2];
def upMomentumLengthLow = if upMomentumStartLow then 1 else if !downMomentumStartLow then upMomentumLengthLow[1] + 1 else 0;
def completedupMomentumLengthLow = if downMomentumStartLow then upMomentumLengthLow[1] else 0;
def downMomentumLengthLow = if downMomentumStartLow then 1 else if !upMomentumStartLow then downMomentumLengthLow[1] + 1 else 0;
def completeddownMomentumLengthLow = if upMomentumStartLow then downMomentumLengthLow[1] else 0;
def upCyclesLow = TotalSum(upMomentumStartLow);
def downCyclesLow = TotalSum(downMomentumStartLow);
def aveUpCycleLengthLow = Round(TotalSum(completedupMomentumLengthLow) / upCyclesLow, 0);
def aveDownCycleLengthLow = Round(TotalSum(completeddownMomentumLengthLow) / downCyclesLow, 0);

def firedLow = !inSqueezeLow and inSqueezeLow[1];
def firedLongLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumLow > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumLow > squeezeMomentumLow[1]));
def firedShortLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumLow <= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumLow < squeezeMomentumLow[1]));
def postSqueezeRunLow = if firedLow then 1 else if inSqueezeLow or downMomentumStartLow or upMomentumStartLow then 0 else postSqueezeRunLow[1];
def postSqueezeRunLengthLow = if postSqueezeRunLow and !(downMomentumStartLow or upMomentumStartLow) then postSqueezeRunLengthLow[1] + 1 else 0;
def completedPostSqueezeRunLow = if !postSqueezeRunLow and postSqueezeRunLow[1] then postSqueezeRunLengthLow[1] else 0;
def postSqueezeRunsLow =  if !postSqueezeRunLow and postSqueezeRunLow[1] then 1 else 0;
def avePostSqueezeRunLow = TotalSum(completedPostSqueezeRunLow) / TotalSum(firedLow);
def pricefiredLow = if firedLow then close[1] else pricefiredLow[1];
def completedPriceMovePercentLow =  if !postSqueezeRunLow and postSqueezeRunLow[1] then AbsValue(100 * (close[1] - pricefiredLow[1]) / pricefiredLow[1]) else 0;
def avePostSqueezePercentLow = TotalSum(completedPriceMovePercentLow) / TotalSum(firedLow);

def squeezeLengthLow = if inSqueezeLow then squeezeLengthLow[1] + 1 else 0;
def completedsqueezeLengthLow = if firedLow then squeezeLengthLow[1] else 0;
def squeezeCountLow = TotalSum(firedLow);
def avesqueezeLengthLow = Round(TotalSum(completedsqueezeLengthLow) / squeezeLengthLow, 0);

def inSqueezeHigh = TTM_Squeeze(price =  price, length = Length, nk = nK_High, nBB = nBB ).SqueezeAlert == 0;
def squeezeMomentumHigh = TTM_Squeeze(price =  price, length = Length, nk = nK_High, nBB = nBB );
def upMomentumStartHigh = squeezeMomentumHigh > squeezeMomentumHigh[1] and squeezeMomentumHigh[1] <= squeezeMomentumHigh[2];
def downMomentumStartHigh = squeezeMomentumHigh < squeezeMomentumHigh[1] and squeezeMomentumHigh[1] >= squeezeMomentumHigh[2];
def upMomentumLengthHigh = if upMomentumStartHigh then 1 else if !downMomentumStartHigh then upMomentumLengthHigh[1] + 1 else 0;
def completedupMomentumLengthHigh = if downMomentumStartHigh then upMomentumLengthHigh[1] else 0;
def downMomentumLengthHigh = if downMomentumStartHigh then 1 else if !upMomentumStartHigh then downMomentumLengthHigh[1] + 1 else 0;
def completeddownMomentumLengthHigh = if upMomentumStartHigh then downMomentumLengthHigh[1] else 0;
def upCyclesHigh = TotalSum(upMomentumStartHigh);
def downCyclesHigh = TotalSum(downMomentumStartHigh);
def aveUpCycleLengthHigh = Round(TotalSum(completedupMomentumLengthHigh) / upCyclesHigh, 0);
def aveDownCycleLengthHigh = Round(TotalSum(completeddownMomentumLengthHigh) / downCyclesHigh, 0);

def firedHigh = !inSqueezeHigh and inSqueezeHigh[1];
def firedLongHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumHigh > 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumHigh > squeezeMomentumHigh[1]));
def firedShortHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and  squeezeMomentumHigh <= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and  squeezeMomentumHigh < squeezeMomentumHigh[1]));
def postSqueezeRunHigh = if firedHigh then 1 else if inSqueezeHigh or downMomentumStartHigh or upMomentumStartHigh then 0 else postSqueezeRunHigh[1];
def postSqueezeRunLengthHigh = if postSqueezeRunHigh and !(downMomentumStartHigh or upMomentumStartHigh) then postSqueezeRunLengthHigh[1] + 1 else 0;
def completedPostSqueezeRunHigh = if !postSqueezeRunHigh and postSqueezeRunHigh[1] then postSqueezeRunLengthHigh[1] else 0;
def postSqueezeRunsHigh =  if !postSqueezeRunHigh and postSqueezeRunHigh[1] then 1 else 0;
def avePostSqueezeRunHigh = TotalSum(completedPostSqueezeRunHigh) / TotalSum(firedHigh);
def pricefiredHigh = if firedHigh then close[1] else pricefiredHigh[1];
def completedPriceMovePercentHigh =  if !postSqueezeRunHigh and postSqueezeRunHigh[1] then AbsValue(100 * (close[1] - pricefiredHigh[1]) / pricefiredHigh[1]) else 0;
def avePostSqueezePercentHigh = TotalSum(completedPriceMovePercentHigh) / TotalSum(firedHigh);

def squeezeLengthHigh = if inSqueezeHigh then squeezeLengthHigh[1] + 1 else 0;
def completedsqueezeLengthHigh = if firedHigh then squeezeLengthHigh[1] else 0;
def squeezeCountHigh = TotalSum(firedHigh);
def avesqueezeLengthHigh = Round(TotalSum(completedsqueezeLengthHigh) / squeezeLengthHigh, 0);

AddLabel(SqueezeType == SqueezeType.All, "**Low** Long: " + totalSum(firedLongLow) + "/Short: " + totalSum(firedShortLow) + "/Ave Run: " + Round(avePostSqueezeRunLow, 0) +  "/Ave Move: " + Round(avePostSqueezePercentLow, 2) + "% = $" + Round(avePostSqueezePercentLow * (close / 100), 2) + "    ", GlobalColor("Low"));

AddLabel(SqueezeType == SqueezeType.All, "**Mid** Long: " + totalSum(firedLong) + "/Short: " + totalSum(firedShort) + "/Ave Run: " + Round(avePostSqueezeRun, 0) +  "/Ave Move: " + Round(avePostSqueezePercent, 2) + "% = $" + Round(avePostSqueezePercent * (close / 100), 2) + "    ", GlobalColor("Mid"));

AddLabel(SqueezeType == SqueezeType.All, "**High** Long: " + totalSum(firedLongHigh) + "/Short: " + totalSum(firedShortHigh) + "/Ave Run: " + Round(avePostSqueezeRunHigh, 0) +  "/Ave Move: " + Round(avePostSqueezePercentHigh, 2) + "% = $" + Round(avePostSqueezePercentHigh * (close / 100), 2) + "    ", GlobalColor("High"));
