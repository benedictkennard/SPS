
# coding: utf-8

# # Background
# 
# Enterococcus is a fecal indicating bacteria that lives in the intestines of humans and other warm-blooded animals. Enterococcus (“Entero”) counts are useful as a water quality indicator due to their abundance in human sewage, correlation with many human pathogens and low abundance in sewage free environments. The United States Environmental Protection Agency (EPA) reports Entero counts as colonies (or cells) per 100 ml of water.
# 
# The organization [Riverkeeper](http://www.riverkeeper.org/) has based its assessment of acceptable water quality on the 2012 Federal Recreational Water Quality Criteria from the US EPA. Unacceptable water is based on an illness rate of 32 per 1000 swimmers. The federal standard for unacceptable water quality is a single sample value of greater than 110 Enterococcus/100 mL, or five or more samples with a geometric mean (a weighted average) greater than 30 Enterococcus/100 mL.
# 
# # Data
# 
# Enterococcus levels in the Hudson River can be found [here](https://github.com/jzuniga123/SPS/blob/master/DATA%20608/riverkeeper_data_2013.csv). 
# 
# # Overview
# 
# Data have not been cleaned and needs to be cleaned. Each question should be a separate dash app. A single app.py for each will be sufficient.
# 
# ## Dowload Data
%%bash
wget https://raw.githubusercontent.com/jzuniga123/SPS/master/DATA%20608/riverkeeper_data_2013.csv
# # Python Libraries

# In[45]:


import pandas as pd
from scipy.stats.mstats import gmean


# # Import Data

# In[9]:


df = pd.read_csv("riverkeeper_data_2013.csv", parse_dates=['Date'])


# ## Pre-process Data
# 
# https://www.riverkeeper.org/water-quality/hudson-river/
# 
# https://www.riverkeeper.org/water-quality/hudson-river/#table

# In[32]:


df.dtypes


# In[59]:


# df['Date'].dt.strftime('%Y-%m-%d')
df['EnteroCount'] = df['EnteroCount'].replace('[^\d]', '', regex=True).astype(int)
df['Acceptable'] = df['EnteroCount'] <= 60
df.head()


# In[96]:


# group by year, rolling geomtric mean take mean of last five samples
# https://pandas.pydata.org/pandas-docs/stable/computation.html#time-aware-rolling
# 
# df.groupby(['Site']).mean().head()
# df.groupby(['Site']).rolling(5, on='EnteroCount', closed='both').sum()
# test = pd.DataFrame(df[['EnteroCount']], index = df[['Site', 'Date']])
test = pd.Series(df['EnteroCount'], index = df[['Site', 'Date']])
# test.set_index(df[['Site', 'Date']])
# test = df[['Site', 'Date', 'EnteroCount']]
# dt_index = pd.to_datetime(test['Date'], format = '%Y-%m-%d')
# test.set_index(dt_index)
test.head()


# # Question 1
# 
# You’re a civic hacker and kayak enthusiast who just came across this dataset. You’d like to create an app that recommends launch sites to users. Ideally an app like this will use live data to give current recommendations, but you’re still in the testing phase. Create a prototype that allows a user to pick a date, and will give its recommendations for that particular date.
# 
# Think about your recommendations . You’re given federal guidelines above, but you may still need to make some assumptions about which sites to recommend. Consider your audience. Users will appreciate some information explaining why a particular site is flagged as unsafe, but they’re not scientists.

# # Question 2
# 
# This time you are building an app for scientists. You’re a public health researcher analyzing this data. You would like to know if there’s a relationship between the amount of rain and water quality. Create an exploratory app that allows other researchers to pick different sites and compare this relationship.

# # References
# 
# https://dash.plot.ly/
# 
# https://github.com/plotly/dash-docs
# 
# https://github.com/plotly/dash-docs/tree/master/tutorial
# 
# ***
# Thread: Dash Applicaton
# 
# Dash user guide can be found here: https://dash.plot.ly/ github repository can be found here: https://github.com/plotly/dash-docs There's a folder named tutorial with many examples.
# ***
# Thread: Dash Functionality
# 
# Did anyone come across issues working with multi-select? Chrome Vs. Firefox browsers. For some reason, the multi-select option is not working in Chrome.
# ***
# Thread: Calculations
# 
# The following paragraph explains calculation for unacceptable water quality "The federal standard for unacceptable water quality is a single sample value of greater than 110 Enterococcus/100 mL, or five or more samples with a geometric mean (a weighted average) greater than 30 Enterococcus/100 mL" I notice "SampleCount" column has values ranging from 27 to 187. My question, how to apply geometric mean to the data? 
# 
# I took it to mean as the number of samples taken.  For example, some sites might have 65 samples.  I also ran into an issue manually counting the sample mean so I used the builtin function for scipy. And by trouble, I mean an overflow issue when using integers (if you are taking larger samples)
# 
# Are you taking Date into account, some of the observations are from different years. 
# 
# No, I had sorted the values by date and then just took the last n samples to create the geometric mean.
# ***
# Thread: Date Picker Problems  
# 
# I'm getting problems when using the date picker. I had a static graph working, and put in a date picker to vary the graph by date. I have a couple  functions that estimate counts based on the closest observations. Any ideas on what I'm doing wrong? Github: https://github.com/AsherMeyers/DATA-608/blob/master/module4/question1/app.py
# 
# To be honest I was toying with the data first, trying to understand what I have and how I can approach it; hence, I haven't started dash yet! ...but based on your output, it seems to me that there seems to be some sort of data type confusion there; it seems that you need data date/time type but it's passing it as string type. Perhaps that might the problem.
# 
# have you set parse_dates=True, inside of pd.read_csv()?
# 
# No but I did convert the dates after reading it in.
# 
# I had to do both parse and the strftime in order for the dash app to read the dates correctly when being passed through the app. 
# 
# 	df = pd.read_csv("riverkeeper_data_2013.csv", parse_dates=['Date'])
# 	df['Date']=df['Date'].dt.strftime('%Y-%m-%d')
# 
# ***
# Thread: [Errno 48] Address already in use  
# 
# I keep getting this error after I successfully run the example dash app code found here: https://dash.plot.ly/getting-started, but I can do repeated runs as I update the code without completely shutting down my machine.
# 
# 	$ ps -fA | grep python
# 
# and then 
# 
# 	$ kill XXXX
# 
# But it's not working...I don't know how to kill the server and then re-run the app. 
# 
# If you are ussing Ubuntu or linux, from terminal you can use (assuming you are running port 8050, if not just change it.
# 
# 	~$ sudo kill $(sudo lsof -t -i:8050)
#     sudo kill $(sudo lsof -t -i:8050)
# 
# It worked!!! Life saver!!!
# ***
# Thread: Safety Calculations
# 
# According to the assignment: "The federal standard for unacceptable water quality is a single sample value of greater than 110 Enterococcus/100 mL, or five or more samples with a geometric mean (a weighted average) greater than 30 Enterococcus/100 mL." How do we calculate this from the total "EnteroCount" which I presume gives the total of all samples, and the SampleCount, which is self-explanatory? For safe levels, one calculation I'd do would be: EnteroCount / SampleCount. This would give the average so any number of samples greater than five and with a calculation over 30, would be unsafe. My question is how would I calculate the first criteria?
# 
# I believe that the geometric average of All Samples for a single day in a single station are given already! Now, If you divide by the number of samples (as you have explained above) it will provide the wrong assumption of safety when in reality is not! that is for example if we have 60 EnteroCount Based on 5 Samples we know that it is NOT safe but if you divide it, it will return 12 making it "SAFE" but is NOT. From my perspective, we can apply the geometric mean to compare different stations or different days/time frames.
# 
# I'm still confused. How would you use EnteroCount and SampleCount to create the two thresholds for safety?
# 
# Easy..."A geometric mean (GM) is a weighted average of multiple samples. If the GM exceeds 30, water is not considered safe for swimming" You can use the EnteroCount as follows: to calculate for example: ACROSS ALL STATIONS. The SampleCount is used to calculate an Statistical Threshold Value.
# ***
# 6:57 PM - Mezu to Everyone: i read online that the solution is to set app.run_server(debug=False) ...have not tried it yet
# 
# 6:58 PM - Duubar Villalobos Jimenez to Everyone: yes, that "problem" occurs when is run as debug=True and then the code crash due to testing
