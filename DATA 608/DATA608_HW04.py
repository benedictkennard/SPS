import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output

app = dash.Dash()
app.config.suppress_callback_exceptions = True

##############################################
# URL BAR
##############################################

app.layout = html.Div([
    dcc.Location(id='url', refresh=False),
    html.Div(id='page-content'),
])

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
})

##############################################
# HOME PAGE
##############################################

markdown_Q1 = '''
### Question 1
You’re a civic hacker and kayak enthusiast who just came across this dataset. You’d like to create an app that recommends launch sites to users. Ideally an app like this will use live data to give current recommendations, but you’re still in the testing phase. Create a prototype that allows a user to pick a date, and will give its recommendations for that particular date. Think about your recommendations . You’re given federal guidelines above, but you may still need to make some assumptions about which sites to recommend. Consider your audience. Users will appreciate some information explaining why a particular site is flagged as unsafe, but they’re not scientists.
'''

markdown_Q2 = '''
### Question 2
This time you are building an app for scientists. You’re a public health researcher analyzing this data. You would like to know if there’s a relationship between the amount of rain and water quality. Create an exploratory app that allows other researchers to pick different sites and compare this relationship.
'''

index_page = html.Div([
    html.H1('Interactive Data Visualizations with Dash'),
    html.H2('Jose Zuniga'),
    dcc.Markdown(children=markdown_Q1),
    dcc.Markdown(children=markdown_Q2),
    dcc.Link('Go to Question 1 Solution', href='/app-1'),
    html.Br(),
    dcc.Link('Go to Question 2 Solution', href='/app-2'),
])

@app.callback(dash.dependencies.Output('page-content', 'children'),
              [dash.dependencies.Input('url', 'pathname')])
def display_page(pathname):
    if pathname == '/app-1':
        return page_1_layout
    elif pathname == '/app-2':
        return page_2_layout
    else:
        return index_page

##############################################
# APPLICATION 1
##############################################

import emoji, pandas as pd
from scipy.stats.mstats import gmean
import plotly.offline as offline
import plotly.graph_objs as go
df1 = pd.read_csv("riverkeeper_data_2013.csv", parse_dates=['Date'])
df1 = df1.set_index(['Site','Date'], drop = True).sort_index()
df1['EnteroCount'] = df1['EnteroCount'].replace('[^\d]', '', regex=True).astype(int)
df1['GeometricMean'] = df1.EnteroCount.groupby(level='Site') \
    .apply(lambda x: x.rolling(5, min_periods=1).apply(gmean))
df1['EPA'] = (df1['EnteroCount'] <= 60).astype(int)
df1['RK'] = (df1['GeometricMean'] <= 30).astype(int)
df1['Both'] = df1['EPA'] + df1['RK']
img1 = emoji.emojize(':poop:', use_aliases=True)
img2 = emoji.emojize(':droplet:', use_aliases=True)
img3 = emoji.emojize(':skull:', use_aliases=True)
img4 = emoji.emojize(':see_no_evil:', use_aliases=True)
img5 = emoji.emojize(':thumbsup:', use_aliases=True)
df1['EPA'] = df1['EPA'].replace([0,1], [img1, img2])
df1['RK'] = df1['RK'].replace([0,1], [img1, img2])
df1['Both'] = df1['Both'].replace([0,1,2], [img3, img4, img5])
sites = df1.index.get_level_values(0).unique()

page_1_layout = html.Div([
    html.H1('Hudson River'),
    ##########################
    dcc.Link('Go to Question 2 Solution', href='/app-2'),
    html.Br(),
    dcc.Link('Go back to Home Page', href='/'),
    ##########################
    html.H2('Site'),
    dcc.Dropdown(
        id='dropdown-site',
        options=[{'label': i, 'value': i} for i in sites],
        placeholder="Select Site",
        clearable=False,
        value='125th St. Pier'
    ),
    html.H2('Date'),
    dcc.Dropdown(id='dropdown-date', 
                 value='2013-10-16'),
    html.H2('Findings'),
    dcc.Graph(id='graph-with-slider'),
])

@app.callback(Output('dropdown-date', 'options'),
              [Input('dropdown-site', 'value')])
def page_1_update_category_options(site):
    dates = df1.loc[site].index.get_level_values(0).unique().sort_values(ascending=False)
    return [{'label': k, 'value': k} for k in dates]

@app.callback(Output('graph-with-slider', 'figure'),
              [Input('dropdown-site', 'value'),
               Input('dropdown-date', 'value')])
def page_1_update_output(input1, input2):
    trace = go.Scatter(
        x = df1.loc[input1]['EnteroCount'].index,
        y = df1.loc[input1]['EnteroCount'],
        mode = 'lines+markers',
        text = df1.loc[input1]['Both']
        )
    layout = go.Layout(
        title='Enterococcus Levels',
        yaxis = dict(title = 'Enterococcus'),
        xaxis=dict(
            title = 'Date Sampled',
            rangeselector=dict(
                buttons=list([
                    dict(count=6, label='6M', step='month', stepmode='backward'),
                    dict(count=1, label='YTD', step='year', stepmode='todate'),
                    dict(count=1, label='1Y', step='year', stepmode='backward'),
                    dict(label='All', step='all')
                ])
            ),
            rangeslider=dict(),
            type='date'
        ),
        annotations=[dict(
                x = input2,
                y = df1.loc[input1].loc[input2]['EnteroCount'],
                text = 'EPA Rating: ' + df1.loc[input1].loc[input2]['EPA'] + \
                    '<br>Riverkeeper: ' + df1.loc[input1].loc[input2]['RK'] + \
                    '<br>Recommendation: ' + df1.loc[input1].loc[input2]['Both'],
                textangle = 0,
                ax = 0,
                ay = -75,
                font = dict(color = "black", size = 12)
        )]
    )
    return {'data': [trace], 'layout': layout}

##############################################
# APPLICATION 2
##############################################

import numpy as np, pandas as pd
import plotly.offline as offline
import plotly.graph_objs as go
df2 = pd.read_csv("riverkeeper_data_2013.csv", parse_dates=['Date'])
df2 = df2.set_index(['Site','Date'], drop = True).sort_index()
df2['EnteroCount'] = df2['EnteroCount'].replace('[^\d]', '', regex=True).astype(int)
df2 = df2.drop('SampleCount', axis=1)
EntroRain = df2.groupby('Site')[['EnteroCount','FourDayRainTotal']] \
    .corr('kendall').iloc[::2] \
    .reset_index(1, drop=True) \
    .drop('EnteroCount', axis=1) \
    .rename(columns={'FourDayRainTotal': 'Correlation'})
sites = df2.index.get_level_values(0).unique()

page_2_layout = html.Div([
    html.H1('Hudson River'),
    ##########################
    dcc.Link('Go to Question 1 Solution', href='/app-1'),
    html.Br(),
    dcc.Link('Go back to Home Page', href='/'),
    ##########################
    html.H2('Site'),
    dcc.Dropdown(
        id='dropdown-site',
        options=[{'label': i, 'value': i} for i in sites],
        placeholder="Select Site",
        clearable=False,
        value='125th St. Pier'
    ),
    html.H2('Correlation'),
    dcc.Graph(id='graph-with-inlet')   
])

@app.callback(Output('graph-with-inlet', 'figure'),
              [Input('dropdown-site', 'value')])
def page_2_update_output(input1):
    ######### MAIN PLOT
    trace0 = go.Scatter(
        x = df2.drop([input1])['FourDayRainTotal'],
        y = df2.drop([input1])['EnteroCount'],
        mode = 'markers',
        hoverinfo = 'none',
        marker = dict(
            size = '10',
            color = 'rgba(204,204,204,1)'
        )
    )
    trace1 = go.Scatter(
        x = df2.loc[input1]['FourDayRainTotal'],
        y = df2.loc[input1]['EnteroCount'],
        mode = 'markers',
        name = input1,
        marker = dict(
            size = '10',
            color = 'rgba(222,45,38,0.8)'
        )
    )
    ############ SUB-PLOT
    bins = np.arange(-1.0, 1.0, 0.1)
    c = ['hsl('+str(h)+',50%'+',50%)' for h in np.linspace(0, 360, len(bins))]
    traceData = [] # info for traces
    for i in range(0, len(bins)):
        k = i if (i <= np.floor(len(bins)/2).astype(int)) else (len(bins) - i + 10)
        trace_iter = go.Bar(
            x = [bins[k]],
            y = ['Correlation'],
            base = 0,
            hoverinfo = 'none',
            orientation = 'h',
            marker=dict(
                color=c[k]
            ),
            xaxis='x2',
            yaxis='y2'
        )
        traceData.append(trace_iter)     
    trace2 = go.Scatter(
        x = EntroRain.loc[input1],
        y = ['Correlation'],
        mode = 'markers',
        name = input1,
        marker=dict(
            symbol = 'star-diamond-dot',
            size = '15',
            color = 'yellow'
        ),
        xaxis='x2',
        yaxis='y2'
    )
    traceData.append(trace0)
    traceData.append(trace1)
    traceData.append(trace2)
    layout = go.Layout(
        title='Enterococcus-Rain Relationship',
        yaxis = dict(title = 'Enterococcus (log)',
                     type = "log",
                     showticklabels=False),
        xaxis = dict(title = 'Four Day Rain Total (inches)'),
        xaxis2=dict(
            zeroline=False,
            domain=[0.75, 0.95],
            anchor='y2'
        ),
        yaxis2=dict(
            showticklabels=False,
            domain=[0.85, 0.95],
            anchor='x2'
        ),
        showlegend=False,
        barmode = 'stack'
    )
    return {'data': traceData, 'layout': layout}

if __name__ == '__main__':
    app.run_server(debug=False, port=8050, host='0.0.0.0')