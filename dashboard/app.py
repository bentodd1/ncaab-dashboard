"""
ESPN Strategy Dashboard - Interactive Web Application
Deploy to Azure: az webapp up --name espn-strategy-dashboard --runtime PYTHON:3.11
"""

import dash
from dash import dcc, html, Input, Output, dash_table
import plotly.graph_objs as go
import plotly.express as px
import pandas as pd
import pyodbc
from datetime import datetime

# Database connection
def get_connection():
    """Create SQL Server connection"""
    conn_str = (
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=MSI\\SQLEXPRESS;'
        'DATABASE=SportsAnalytics;'
        'Trusted_Connection=yes;'
    )
    return pyodbc.connect(conn_str)

# Data fetching functions
def get_strategy_comparison(season=None, min_edge=3, conference_type=None):
    """Get comparison of all three strategies"""
    conn = get_connection()

    season_filter = f"AND v.SeasonYear = '{season}'" if season else ""
    conf_join = ""
    conf_filter = ""

    if conference_type and conference_type != 'ALL':
        conf_join = "INNER JOIN dbo.vw_GamesWithConferences c ON v.GameID = c.GameID"
        conf_filter = f"AND c.HomeConferenceType = '{conference_type}'"

    query = f"""
    SELECT
        'ESPN vs Consensus' AS Strategy,
        COUNT(*) AS Games,
        SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CAST(SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
            SUM(CASE WHEN v.CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPct,
        (SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
        (SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS Profit
    FROM dbo.vw_ESPNFavorsUnderdog v
    {conf_join}
    WHERE ABS(v.ESPNEdge) >= {min_edge} AND v.CoverResult IS NOT NULL {season_filter} {conf_filter}

    UNION ALL

    SELECT
        'ESPN vs Opening Line' AS Strategy,
        COUNT(*) AS Games,
        SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CAST(SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
            SUM(CASE WHEN v.CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPct,
        (SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
        (SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS Profit
    FROM dbo.vw_ESPNvsOpeningLine v
    {conf_join}
    WHERE ABS(v.ESPNEdge) >= {min_edge} AND v.CoverResult IS NOT NULL {season_filter} {conf_filter}

    UNION ALL

    SELECT
        'ESPN vs Closing Line' AS Strategy,
        COUNT(*) AS Games,
        SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CAST(SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
            SUM(CASE WHEN v.CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPct,
        (SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
        (SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS Profit
    FROM dbo.vw_ESPNvsClosingLine v
    {conf_join}
    WHERE ABS(v.ESPNEdge) >= {min_edge} AND v.CoverResult IS NOT NULL {season_filter} {conf_filter}
    """
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def get_performance_by_season(season=None, min_edge=3):
    """Get performance data filtered by season"""
    conn = get_connection()

    season_filter = f"AND SeasonYear = '{season}'" if season else ""

    query = f"""
    SELECT
        SeasonYear,
        COUNT(*) AS TotalGames,
        SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CAST(SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
            SUM(CASE WHEN CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END) * 100 AS WinPct,
        (SUM(CASE WHEN CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
        (SUM(CASE WHEN CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS Profit
    FROM dbo.vw_ESPNFavorsUnderdog
    WHERE ABS(ESPNEdge) >= {min_edge} AND CoverResult IS NOT NULL {season_filter}
    GROUP BY SeasonYear
    ORDER BY SeasonYear
    """
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def get_available_seasons():
    """Get list of available seasons"""
    conn = get_connection()
    df = pd.read_sql("SELECT DISTINCT SeasonYear FROM dbo.Seasons WHERE SportID = 1 ORDER BY SeasonYear", conn)
    conn.close()
    return df['SeasonYear'].tolist()

def get_recent_picks(season=None, limit=20):
    """Get recent ESPN picks"""
    conn = get_connection()

    season_filter = f"AND SeasonYear = '{season}'" if season else ""

    query = f"""
    SELECT TOP {limit}
        GameDate,
        HomeTeam,
        RoadTeam,
        ConsensusLine,
        ESPNLine,
        ESPNEdge,
        HomeScore,
        RoadScore,
        CoverResult
    FROM dbo.vw_ESPNFavorsUnderdog
    WHERE ABS(ESPNEdge) >= 3 {season_filter}
    ORDER BY GameDate DESC
    """
    df = pd.read_sql(query, conn)
    conn.close()
    return df

def get_conference_comparison(season=None, min_edge=3):
    """Get performance by conference type - shows all types for comparison"""
    conn = get_connection()

    season_filter = f"AND v.SeasonYear = '{season}'" if season else ""

    query = f"""
    SELECT
        c.HomeConferenceType AS ConferenceType,
        COUNT(*) AS TotalGames,
        SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS Wins,
        SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) AS Losses,
        CAST(SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) AS FLOAT) /
            NULLIF(SUM(CASE WHEN v.CoverResult IN ('COVERED', 'MISSED') THEN 1 ELSE 0 END), 0) * 100 AS WinPct,
        (SUM(CASE WHEN v.CoverResult = 'COVERED' THEN 1 ELSE 0 END) * 100) -
        (SUM(CASE WHEN v.CoverResult = 'MISSED' THEN 1 ELSE 0 END) * 110) AS Profit
    FROM dbo.vw_ESPNFavorsUnderdog v
    INNER JOIN dbo.vw_GamesWithConferences c ON v.GameID = c.GameID
    WHERE ABS(v.ESPNEdge) >= {min_edge} AND v.CoverResult IS NOT NULL
        AND c.HomeConferenceType != 'Unknown' {season_filter}
    GROUP BY c.HomeConferenceType
    ORDER BY WinPct DESC
    """
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Initialize Dash app
app = dash.Dash(__name__, suppress_callback_exceptions=True)
server = app.server  # For Azure deployment

# App layout
app.layout = html.Div([
    html.Div([
        html.H1('ESPN BPI Strategy Dashboard',
                style={'textAlign': 'center', 'color': '#2c3e50', 'marginBottom': 10}),
        html.H3('NCAA Basketball Prediction Analysis',
                style={'textAlign': 'center', 'color': '#7f8c8d', 'marginTop': 0}),
    ], style={'backgroundColor': '#ecf0f1', 'padding': '20px'}),

    # Filters
    html.Div([
        html.Div([
            html.Label('Season Filter:', style={'fontWeight': 'bold'}),
            dcc.Dropdown(
                id='season-dropdown',
                options=[{'label': 'All Seasons', 'value': 'ALL'}] +
                        [{'label': season, 'value': season} for season in get_available_seasons()],
                value='ALL',
                style={'width': '200px'}
            ),
        ], style={'display': 'inline-block', 'marginRight': '20px'}),

        html.Div([
            html.Label('Minimum Edge:', style={'fontWeight': 'bold'}),
            dcc.Dropdown(
                id='edge-dropdown',
                options=[
                    {'label': '3 points', 'value': 3},
                    {'label': '5 points', 'value': 5},
                    {'label': '7 points', 'value': 7},
                ],
                value=3,
                style={'width': '150px'}
            ),
        ], style={'display': 'inline-block', 'marginRight': '20px'}),

        html.Div([
            html.Label('Conference Type:', style={'fontWeight': 'bold'}),
            dcc.Dropdown(
                id='conference-dropdown',
                options=[
                    {'label': 'All Conferences', 'value': 'ALL'},
                    {'label': 'Major (Power 6)', 'value': 'Major'},
                    {'label': 'Mid-Major', 'value': 'Mid-Major'},
                    {'label': 'Minor', 'value': 'Minor'},
                ],
                value='ALL',
                style={'width': '200px'}
            ),
        ], style={'display': 'inline-block'}),

    ], style={'padding': '20px', 'backgroundColor': '#f8f9fa'}),

    # Strategy Comparison Section
    html.Div([
        html.H2('Strategy Comparison', style={'color': '#2c3e50'}),
        html.P('Comparing ESPN predictions against different benchmarks',
               style={'color': '#7f8c8d'}),
        dcc.Graph(id='strategy-comparison-chart'),
        html.Div(id='strategy-table'),
    ], style={'padding': '20px', 'backgroundColor': 'white', 'margin': '20px', 'borderRadius': '5px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),

    # Performance by Season
    html.Div([
        html.H2('Performance by Season', style={'color': '#2c3e50'}),
        dcc.Graph(id='season-performance-chart'),
    ], style={'padding': '20px', 'backgroundColor': 'white', 'margin': '20px', 'borderRadius': '5px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),

    # Conference Performance Comparison
    html.Div([
        html.H2('Performance by Conference Type', style={'color': '#2c3e50'}),
        html.P('Compare win rates across Major, Mid-Major, and Minor conferences',
               style={'color': '#7f8c8d'}),
        dcc.Graph(id='conference-comparison-chart'),
        html.Div(id='conference-table'),
    ], style={'padding': '20px', 'backgroundColor': 'white', 'margin': '20px', 'borderRadius': '5px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),

    # Recent Picks
    html.Div([
        html.H2('Recent Picks', style={'color': '#2c3e50'}),
        html.Div(id='recent-picks-table'),
    ], style={'padding': '20px', 'backgroundColor': 'white', 'margin': '20px', 'borderRadius': '5px', 'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'}),

    # Footer
    html.Div([
        html.P(f'Last updated: {datetime.now().strftime("%Y-%m-%d %H:%M")} | Data: 2021-22 through 2023-24 seasons',
               style={'textAlign': 'center', 'color': '#95a5a6', 'fontSize': '12px'})
    ], style={'padding': '20px'}),
])

# Callbacks
@app.callback(
    [Output('strategy-comparison-chart', 'figure'),
     Output('strategy-table', 'children')],
    [Input('season-dropdown', 'value'),
     Input('edge-dropdown', 'value'),
     Input('conference-dropdown', 'value')]
)
def update_strategy_comparison(season, min_edge, conference_type):
    season_param = None if season == 'ALL' else season
    conf_param = None if conference_type == 'ALL' else conference_type
    df = get_strategy_comparison(season_param, min_edge, conf_param)

    # Check if dataframe is empty or has no valid data
    if df.empty or len(df) == 0 or df['Profit'].isna().all():
        fig = go.Figure()
        fig.add_annotation(
            text="No data available for selected filters",
            xref="paper", yref="paper",
            x=0.5, y=0.5, showarrow=False,
            font=dict(size=16)
        )
        table = html.P("No data available", style={'color': '#95a5a6'})
        return fig, table

    # Fill NaN values with 0 for safety
    df = df.fillna(0)

    # Create bar chart
    fig = go.Figure(data=[
        go.Bar(name='Profit/Loss', x=df['Strategy'], y=df['Profit'],
               marker_color=['green' if x > 0 else 'red' for x in df['Profit']],
               text=[f'${x:,.0f}' for x in df['Profit']],
               textposition='outside')
    ])

    fig.update_layout(
        title='Profitability Comparison',
        yaxis_title='Profit/Loss (per $100 bet)',
        showlegend=False,
        height=400
    )

    # Create data table
    df_display = df.copy()
    df_display['WinPct'] = df_display['WinPct'].round(2).astype(str) + '%'
    df_display['Profit'] = df_display['Profit'].apply(lambda x: f'${x:,.0f}')

    table = dash_table.DataTable(
        data=df_display.to_dict('records'),
        columns=[{'name': i, 'id': i} for i in df_display.columns],
        style_cell={'textAlign': 'left', 'padding': '10px'},
        style_header={'backgroundColor': '#3498db', 'color': 'white', 'fontWeight': 'bold'},
        style_data_conditional=[
            {
                'if': {'row_index': 0},
                'backgroundColor': '#d5f4e6',
                'fontWeight': 'bold'
            }
        ]
    )

    return fig, table

@app.callback(
    Output('season-performance-chart', 'figure'),
    [Input('season-dropdown', 'value'),
     Input('edge-dropdown', 'value')]
)
def update_season_performance(season, min_edge):
    season_param = None if season == 'ALL' else season
    df = get_performance_by_season(season_param, min_edge)

    fig = go.Figure()

    # Add profit bars
    fig.add_trace(go.Bar(
        name='Profit/Loss',
        x=df['SeasonYear'],
        y=df['Profit'],
        marker_color=['green' if x > 0 else 'red' for x in df['Profit']],
        yaxis='y',
        text=[f'${x:,.0f}' for x in df['Profit']],
        textposition='outside'
    ))

    # Add win percentage line
    fig.add_trace(go.Scatter(
        name='Win %',
        x=df['SeasonYear'],
        y=df['WinPct'],
        yaxis='y2',
        mode='lines+markers',
        line=dict(color='blue', width=3),
        marker=dict(size=10)
    ))

    fig.update_layout(
        title='Profit and Win Rate by Season',
        yaxis=dict(title='Profit/Loss ($)'),
        yaxis2=dict(title='Win Percentage (%)', overlaying='y', side='right'),
        hovermode='x unified',
        height=400
    )

    return fig

@app.callback(
    Output('recent-picks-table', 'children'),
    [Input('season-dropdown', 'value')]
)
def update_recent_picks(season):
    season_param = None if season == 'ALL' else season
    df = get_recent_picks(season_param)

    df_display = df.copy()
    df_display['GameDate'] = pd.to_datetime(df_display['GameDate']).dt.strftime('%Y-%m-%d')
    df_display['Matchup'] = df_display['HomeTeam'] + ' vs ' + df_display['RoadTeam']
    df_display = df_display[['GameDate', 'Matchup', 'ConsensusLine', 'ESPNLine', 'ESPNEdge', 'CoverResult']]

    table = dash_table.DataTable(
        data=df_display.to_dict('records'),
        columns=[{'name': i, 'id': i} for i in df_display.columns],
        style_cell={'textAlign': 'left', 'padding': '10px'},
        style_header={'backgroundColor': '#3498db', 'color': 'white', 'fontWeight': 'bold'},
        style_data_conditional=[
            {
                'if': {
                    'filter_query': '{CoverResult} = "COVERED"',
                    'column_id': 'CoverResult'
                },
                'backgroundColor': '#d5f4e6',
                'color': 'green',
                'fontWeight': 'bold'
            },
            {
                'if': {
                    'filter_query': '{CoverResult} = "MISSED"',
                    'column_id': 'CoverResult'
                },
                'backgroundColor': '#fadbd8',
                'color': 'red',
                'fontWeight': 'bold'
            }
        ],
        page_size=20
    )

    return table

@app.callback(
    [Output('conference-comparison-chart', 'figure'),
     Output('conference-table', 'children')],
    [Input('season-dropdown', 'value'),
     Input('edge-dropdown', 'value')]
)
def update_conference_comparison(season, min_edge):
    season_param = None if season == 'ALL' else season
    df = get_conference_comparison(season_param, min_edge)

    if df.empty:
        # No data available
        fig = go.Figure()
        fig.add_annotation(
            text="No data available for selected filters",
            xref="paper", yref="paper",
            x=0.5, y=0.5, showarrow=False,
            font=dict(size=16)
        )
        table = html.P("No data available", style={'color': '#95a5a6'})
        return fig, table

    # Create bar chart
    fig = go.Figure()

    # Add win percentage bars
    fig.add_trace(go.Bar(
        name='Win %',
        x=df['ConferenceType'],
        y=df['WinPct'],
        marker_color=['#27ae60' if x > 52.4 else '#e74c3c' for x in df['WinPct']],
        text=[f'{x:.1f}%' for x in df['WinPct']],
        textposition='outside',
        yaxis='y'
    ))

    # Add profit line
    fig.add_trace(go.Scatter(
        name='Profit/Loss',
        x=df['ConferenceType'],
        y=df['Profit'],
        yaxis='y2',
        mode='lines+markers',
        line=dict(color='#3498db', width=3),
        marker=dict(size=10),
        text=[f'${x:,.0f}' for x in df['Profit']],
        hovertemplate='%{text}<extra></extra>'
    ))

    # Add breakeven line
    fig.add_hline(y=52.4, line_dash="dash", line_color="gray",
                  annotation_text="Breakeven (52.4%)", yref='y')

    fig.update_layout(
        title='Win Rate and Profitability by Conference Type',
        yaxis=dict(title='Win Percentage (%)'),
        yaxis2=dict(title='Profit/Loss ($)', overlaying='y', side='right'),
        hovermode='x unified',
        height=400,
        showlegend=True
    )

    # Create data table
    df_display = df.copy()
    df_display['WinPct'] = df_display['WinPct'].round(2).astype(str) + '%'
    df_display['Profit'] = df_display['Profit'].apply(lambda x: f'${x:,.0f}')
    df_display.rename(columns={
        'ConferenceType': 'Conference Type',
        'TotalGames': 'Games',
        'WinPct': 'Win %',
        'Profit': 'Profit/Loss'
    }, inplace=True)

    table = dash_table.DataTable(
        data=df_display.to_dict('records'),
        columns=[{'name': i, 'id': i} for i in df_display.columns],
        style_cell={'textAlign': 'left', 'padding': '10px'},
        style_header={'backgroundColor': '#3498db', 'color': 'white', 'fontWeight': 'bold'},
        style_data_conditional=[
            {
                'if': {'row_index': 0},
                'backgroundColor': '#d5f4e6',
                'fontWeight': 'bold'
            }
        ]
    )

    return fig, table

if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0', port=8050)
