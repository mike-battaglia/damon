input enableAllAlerts = YES;

declare lower;

def nBB = 2.0; 
def Length = 20.0; 
def nK_High = 1.0; 
def nK_Mid = 1.5;
def nK_Low = 2.0;  
def price = close;

def momentum = TTM_Squeeze(price = price, length = length, nk = nk_Mid, nbb = nbb)."Histogram";
def BolKelDelta_Mid = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_Mid, "length" = Length)."Upper_Band";
def BolKelDelta_Low = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_Low, "length" = Length)."Upper_Band";
def BolKelDelta_High = reference BollingerBands("num_dev_up" = nBB, "length" = Length )."upperband" - KeltnerChannels("factor" = nK_High, "length" = Length)."Upper_Band";

plot squeeze = If(IsNaN(close), Double.NaN, 0);
squeeze.DefineColor("NoSqueeze", Color.green);
squeeze.DefineColor("SqueezeLow", Color.black);
squeeze.DefineColor("SqueezeMid", Color.red);
squeeze.DefineColor("SqueezeHigh", Color.orange);
squeeze.AssignValueColor(if BolKelDelta_High <= 0 then squeeze.Color("SqueezeHigh") else if BolKelDelta_Mid <= 0 then squeeze.Color("SqueezeMid") else if BolKelDelta_Low <= 0 then squeeze.Color("SqueezeLow") else squeeze.color("noSqueeze"));
#squeeze.SetPaintingStrategy(PaintingStrategy.POINTS);
#squeeze.SetLineWeight(3);

def sLow = BolKelDelta_Low <= 0;
def sMid = BolKelDelta_Mid <= 0;
def sHigh = BolKelDelta_High <= 0;
def shqueeze = if TTM_Squeeze () .SqueezeAlert == 0 then 1 else 0;
def sumShqueeze = Sum(shqueeze, 10);
def shqueezeFired = if TTM_Squeeze () .SqueezeAlert[1] == 0 AND TTM_Squeeze().SqueezeAlert == 1 then 1 else 0;

AddLabel( sLow,"Low "+sumShqueeze,color.white);
AddLabel( sMid,"Mid "+sumShqueeze,color.white);
AddLabel( sHigh,"High "+sumShqueeze,color.white);
AddLabel( !sLow and !sMid and !sHigh, "None");
AssignBackgroundColor( if sLow and !sMid and !sHigh then color.dark_green else if sMid and !sHigh then color.dark_red else if sHigh then color.dark_orange else color.black);
