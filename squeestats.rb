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

DefineGlobalColor(&quot;SqueezeStats&quot;, color.white);
DefineGlobalColor(&quot;CurrentSqueeze&quot;, color.yellow);
DefineGlobalColor(&quot;RisingHistogramStats&quot;, color.cyan);
DefineGlobalColor(&quot;FallingHistogramStats&quot;, color.red);
DefineGlobalColor(&quot;PostSqueezeStats&quot;, color.orange);

DefineGlobalColor(&quot;Low&quot;, color.light_gray);
DefineGlobalColor(&quot;Mid&quot;, color.pink);
DefineGlobalColor(&quot;High&quot;, color.orange);

def selectedNK = if SqueezeType == SqueezeType.Mid then nK_Mid else if SqueezeType ==
SqueezeType.Low then nK_Low else if SqueezeType == SqueezeType.High then nK_High else nK_Mid;

def inSqueeze = TTM_Squeeze(price = price, length = Length, nk = selectedNK, nBB = nBB ).SqueezeAlert
== 0;
def squeezeMomentum = TTM_Squeeze(price = price, length = Length, nk = selectedNK, nBB = nBB );
def upMomentumStart = squeezeMomentum &gt; squeezeMomentum[1] and squeezeMomentum[1] &lt;=
squeezeMomentum[2];
def downMomentumStart = squeezeMomentum &lt; squeezeMomentum[1] and squeezeMomentum[1]
&gt;= squeezeMomentum[2];
def upMomentumLength = if upMomentumStart then 1 else if !downMomentumStart then
upMomentumLength[1] + 1 else 0;
def completedUpMomentumLength = if downMomentumStart then upMomentumLength[1] else 0;
def downMomentumLength = if downMomentumStart then 1 else if !upMomentumStart then
downMomentumLength[1] + 1 else 0;
def completedDownMomentumLength = if upMomentumStart then downMomentumLength[1] else 0;
def upCycles = TotalSum(upMomentumStart);
def downCycles = TotalSum(downMomentumStart);
def aveUpCycleLength = Round(TotalSum(completedUpMomentumLength) / upCycles, 0);
def aveDownCycleLength = Round(TotalSum(completedDownMomentumLength) / downCycles, 0);

def fired = !inSqueeze and inSqueeze[1];
def firedLong = fired and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and
squeezeMomentum &gt; 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and
squeezeMomentum &gt; squeezeMomentum[1]));
def firedShort = fired and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and
squeezeMomentum &lt;= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and
squeezeMomentum &lt; squeezeMomentum[1]));
def postSqueezeRun = if fired then 1 else if inSqueeze or downMomentumStart or upMomentumStart
then 0 else postSqueezeRun[1];
def postSqueezeRunLength = if postSqueezeRun and !(downMomentumStart or upMomentumStart)
then postSqueezeRunLength[1] + 1 else 0;
def completedPostSqueezeRun = if !postSqueezeRun and postSqueezeRun[1] then
postSqueezeRunLength[1] else 0;
def postSqueezeRuns = if !postSqueezeRun and postSqueezeRun[1] then 1 else 0;
def avePostSqueezeRun = TotalSum(completedPostSqueezeRun) / TotalSum(fired);

def priceFired = if fired then close[1] else priceFired[1];
def completedPriceMovePercent = if !postSqueezeRun and postSqueezeRun[1] then AbsValue(100 *
(close[1] - priceFired[1]) / priceFired[1]) else 0;
def avePostSqueezePercent = TotalSum(completedPriceMovePercent) / TotalSum(fired);

def squeezeLength = if inSqueeze then squeezeLength[1] + 1 else 0;
def completedSqueezeLength = if fired then squeezeLength[1] else 0;
def squeezeCount = TotalSum(fired);
def aveSqueezeLength = Round(TotalSum(completedSqueezeLength) / squeezeCount, 0);

AddLabel(SqueezeType != SqueezeType.All, if SqueezeType == SqueezeType.Mid then &quot;MID&quot; else if
SqueezeType == SqueezeType.Low then &quot;LOW&quot; else &quot;HIGH&quot;, if SqueezeType == SqueezeType.Mid then
color.red else if SqueezeType == SqueezeType.Low then color.black else color.DARK_ORANGE);
AddLabel(SqueezeType != SqueezeType.All, &quot;Squeeze Count: &quot; + squeezeCount,
GlobalColor(&quot;SqueezeStats&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Fired Long: &quot; + totalSum(firedLong),
GlobalColor(&quot;SqueezeStats&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Fired Short: &quot; + totalSum(firedShort),
GlobalColor(&quot;SqueezeStats&quot;));

AddLabel(SqueezeType != SqueezeType.All, &quot;Ave Squeeze Length: &quot; + aveSqueezeLength,
GlobalColor(&quot;SqueezeStats&quot;));
AddLabel(inSqueeze, &quot;Current Squeeze: &quot; + squeezeLength, GlobalColor(&quot;CurrentSqueeze&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Ave Rising Hist: &quot; + aveUpCycleLength,
GlobalColor(&quot;RisingHistogramStats&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Ave Falling Hist: &quot; + aveDownCycleLength,
GlobalColor(&quot;FallingHistogramStats&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Ave Post Squeeze Run: &quot; + Round(avePostSqueezeRun, 0),
GlobalColor(&quot;PostSqueezeStats&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Longest Post Squeeze Run: &quot; +
HighestAll(completedPostSqueezeRun), GlobalColor(&quot;PostSqueezeStats&quot;));

AddLabel(SqueezeType != SqueezeType.All, &quot;Ave Post Squeeze Move: &quot; +
Round(avePostSqueezePercent, 2) + &quot;% = $&quot; + Round(avePostSqueezePercent * (close / 100), 2),
GlobalColor(&quot;PostSqueezeStats&quot;));
AddLabel(SqueezeType != SqueezeType.All, &quot;Biggest Post Squeeze Move: &quot; +
Round(HighestAll(completedPriceMovePercent) , 2) + &quot;% = $&quot; +
Round(HighestAll(completedPriceMovePercent) * (close / 100), 2), GlobalColor(&quot;PostSqueezeStats&quot;));

def inSqueezeLow = TTM_Squeeze(price = price, length = Length, nk = nK_Low, nBB = nBB
).SqueezeAlert == 0;
def squeezeMomentumLow = TTM_Squeeze(price = price, length = Length, nk = nK_Low, nBB = nBB );
def upMomentumStartLow = squeezeMomentumLow &gt; squeezeMomentumLow[1] and
squeezeMomentumLow[1] &lt;= squeezeMomentumLow[2];
def downMomentumStartLow = squeezeMomentumLow &lt; squeezeMomentumLow[1] and
squeezeMomentumLow[1] &gt;= squeezeMomentumLow[2];
def upMomentumLengthLow = if upMomentumStartLow then 1 else if !downMomentumStartLow then
upMomentumLengthLow[1] + 1 else 0;
def completedupMomentumLengthLow = if downMomentumStartLow then
upMomentumLengthLow[1] else 0;
def downMomentumLengthLow = if downMomentumStartLow then 1 else if !upMomentumStartLow
then downMomentumLengthLow[1] + 1 else 0;
def completeddownMomentumLengthLow = if upMomentumStartLow then
downMomentumLengthLow[1] else 0;
def upCyclesLow = TotalSum(upMomentumStartLow);
def downCyclesLow = TotalSum(downMomentumStartLow);
def aveUpCycleLengthLow = Round(TotalSum(completedupMomentumLengthLow) / upCyclesLow, 0);
def aveDownCycleLengthLow = Round(TotalSum(completeddownMomentumLengthLow) /
downCyclesLow, 0);

def firedLow = !inSqueezeLow and inSqueezeLow[1];
def firedLongLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero and
squeezeMomentumLow &gt; 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and
squeezeMomentumLow &gt; squeezeMomentumLow[1]));

def firedShortLow = firedLow and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero
and squeezeMomentumLow &lt;= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and
squeezeMomentumLow &lt; squeezeMomentumLow[1]));
def postSqueezeRunLow = if firedLow then 1 else if inSqueezeLow or downMomentumStartLow or
upMomentumStartLow then 0 else postSqueezeRunLow[1];
def postSqueezeRunLengthLow = if postSqueezeRunLow and !(downMomentumStartLow or
upMomentumStartLow) then postSqueezeRunLengthLow[1] + 1 else 0;
def completedPostSqueezeRunLow = if !postSqueezeRunLow and postSqueezeRunLow[1] then
postSqueezeRunLengthLow[1] else 0;
def postSqueezeRunsLow = if !postSqueezeRunLow and postSqueezeRunLow[1] then 1 else 0;
def avePostSqueezeRunLow = TotalSum(completedPostSqueezeRunLow) / TotalSum(firedLow);
def pricefiredLow = if firedLow then close[1] else pricefiredLow[1];
def completedPriceMovePercentLow = if !postSqueezeRunLow and postSqueezeRunLow[1] then
AbsValue(100 * (close[1] - pricefiredLow[1]) / pricefiredLow[1]) else 0;
def avePostSqueezePercentLow = TotalSum(completedPriceMovePercentLow) / TotalSum(firedLow);

def squeezeLengthLow = if inSqueezeLow then squeezeLengthLow[1] + 1 else 0;
def completedsqueezeLengthLow = if firedLow then squeezeLengthLow[1] else 0;
def squeezeCountLow = TotalSum(firedLow);
def avesqueezeLengthLow = Round(TotalSum(completedsqueezeLengthLow) / squeezeLengthLow, 0);

def inSqueezeHigh = TTM_Squeeze(price = price, length = Length, nk = nK_High, nBB = nBB
).SqueezeAlert == 0;
def squeezeMomentumHigh = TTM_Squeeze(price = price, length = Length, nk = nK_High, nBB = nBB );
def upMomentumStartHigh = squeezeMomentumHigh &gt; squeezeMomentumHigh[1] and
squeezeMomentumHigh[1] &lt;= squeezeMomentumHigh[2];
def downMomentumStartHigh = squeezeMomentumHigh &lt; squeezeMomentumHigh[1] and
squeezeMomentumHigh[1] &gt;= squeezeMomentumHigh[2];
def upMomentumLengthHigh = if upMomentumStartHigh then 1 else if !downMomentumStartHigh
then upMomentumLengthHigh[1] + 1 else 0;
def completedupMomentumLengthHigh = if downMomentumStartHigh then
upMomentumLengthHigh[1] else 0;

def downMomentumLengthHigh = if downMomentumStartHigh then 1 else if !upMomentumStartHigh
then downMomentumLengthHigh[1] + 1 else 0;
def completeddownMomentumLengthHigh = if upMomentumStartHigh then
downMomentumLengthHigh[1] else 0;
def upCyclesHigh = TotalSum(upMomentumStartHigh);
def downCyclesHigh = TotalSum(downMomentumStartHigh);
def aveUpCycleLengthHigh = Round(TotalSum(completedupMomentumLengthHigh) / upCyclesHigh, 0);
def aveDownCycleLengthHigh = Round(TotalSum(completeddownMomentumLengthHigh) /
downCyclesHigh, 0);

def firedHigh = !inSqueezeHigh and inSqueezeHigh[1];
def firedLongHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero
and squeezeMomentumHigh &gt; 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and
squeezeMomentumHigh &gt; squeezeMomentumHigh[1]));
def firedShortHigh = firedHigh and ((LongShortDefinition == LongShortDefinition.HistAboveBelowZero
and squeezeMomentumHigh &lt;= 0) or (LongShortDefinition == LongShortDefinition.HistRisingFalling and
squeezeMomentumHigh &lt; squeezeMomentumHigh[1]));
def postSqueezeRunHigh = if firedHigh then 1 else if inSqueezeHigh or downMomentumStartHigh or
upMomentumStartHigh then 0 else postSqueezeRunHigh[1];
def postSqueezeRunLengthHigh = if postSqueezeRunHigh and !(downMomentumStartHigh or
upMomentumStartHigh) then postSqueezeRunLengthHigh[1] + 1 else 0;
def completedPostSqueezeRunHigh = if !postSqueezeRunHigh and postSqueezeRunHigh[1] then
postSqueezeRunLengthHigh[1] else 0;
def postSqueezeRunsHigh = if !postSqueezeRunHigh and postSqueezeRunHigh[1] then 1 else 0;
def avePostSqueezeRunHigh = TotalSum(completedPostSqueezeRunHigh) / TotalSum(firedHigh);
def pricefiredHigh = if firedHigh then close[1] else pricefiredHigh[1];
def completedPriceMovePercentHigh = if !postSqueezeRunHigh and postSqueezeRunHigh[1] then
AbsValue(100 * (close[1] - pricefiredHigh[1]) / pricefiredHigh[1]) else 0;
def avePostSqueezePercentHigh = TotalSum(completedPriceMovePercentHigh) / TotalSum(firedHigh);

def squeezeLengthHigh = if inSqueezeHigh then squeezeLengthHigh[1] + 1 else 0;
def completedsqueezeLengthHigh = if firedHigh then squeezeLengthHigh[1] else 0;
def squeezeCountHigh = TotalSum(firedHigh);

def avesqueezeLengthHigh = Round(TotalSum(completedsqueezeLengthHigh) / squeezeLengthHigh, 0);

AddLabel(SqueezeType == SqueezeType.All, &quot;**Low** Long: &quot; + totalSum(firedLongLow) + &quot;/Short: &quot; +
totalSum(firedShortLow) + &quot;/Ave Run: &quot; + Round(avePostSqueezeRunLow, 0) + &quot;/Ave Move: &quot; +
Round(avePostSqueezePercentLow, 2) + &quot;% = $&quot; + Round(avePostSqueezePercentLow * (close / 100), 2)
+ &quot; &quot;, GlobalColor(&quot;Low&quot;));

AddLabel(SqueezeType == SqueezeType.All, &quot;**Mid** Long: &quot; + totalSum(firedLong) + &quot;/Short: &quot; +
totalSum(firedShort) + &quot;/Ave Run: &quot; + Round(avePostSqueezeRun, 0) + &quot;/Ave Move: &quot; +
Round(avePostSqueezePercent, 2) + &quot;% = $&quot; + Round(avePostSqueezePercent * (close / 100), 2) + &quot; &quot;,
GlobalColor(&quot;Mid&quot;));

AddLabel(SqueezeType == SqueezeType.All, &quot;**High** Long: &quot; + totalSum(firedLongHigh) + &quot;/Short: &quot; +
totalSum(firedShortHigh) + &quot;/Ave Run: &quot; + Round(avePostSqueezeRunHigh, 0) + &quot;/Ave Move: &quot; +
Round(avePostSqueezePercentHigh, 2) + &quot;% = $&quot; + Round(avePostSqueezePercentHigh * (close / 100), 2)
+ &quot; &quot;, GlobalColor(&quot;High&quot;));
