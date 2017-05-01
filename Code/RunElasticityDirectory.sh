# Run the analysis code for the Elasticity of Labor Supply paper in the appropriate order

# Parse the ASC into each year & clean each year
# calls 1-CleanACS.do inside the script, once for each year
# calls 1-ImputeAndInstrument.do as well.
stata do 1-ParseACS.do

# generate descriptive tables & analysis tables
stata do 2-DescriptiveAnalysis.do
stata do 3-MainAnalysis.do 
stata do 4-PopAnalysis.do

