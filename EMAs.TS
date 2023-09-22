# Plot MA Stacks. Don't forget to use with ST_SqueezePRO_Scan("squeeze type" = "High")

def EMA8 = ExpAverage(close, 8);
def EMA21 = ExpAverage(close, 21);
# def EMAc = ExpAverage(close, 34);
def EMA50 = SimpleMovingAvg(close, 50);
def EMA200 = SimpleMovingAvg(close, 200);

def bullStacked = EMA8 > EMA21 and EMA21 > EMA50 and EMA50 > EMA200;

def bearStacked = EMA8 < EMA21 and EMA21 < EMA50 and EMA50 < EMA200;

def bullStackedPlot = bullStacked and !bullStacked[1];

plot bearStackedPlot = bearStacked and !bearStacked[1];

# def bearStackedPlot = bearStacked;

# plot bullStackedPlot = bullStacked;

# The plot statements are used to visualize the results on the chart. The bullStackedPlot is plotted when the bullStacked condition is true and the previous bar did not satisfy the bullStacked condition. The bearStackedPlot is plotted when the bearStacked condition is true and the previous bar did not satisfy the bearStacked condition.
