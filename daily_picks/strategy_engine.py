"""
Strategy Engine
Applies monthly betting strategies to game edges
"""

from datetime import datetime


# Monthly strategies from STRATEGY_PLAYBOOK.md
STRATEGIES = {
    11: [  # November
        {
            'name': 'November Minor Underdog',
            'conference': 'Minor',
            'min_edge': 4,
            'direction': 'UNDERDOG',
            'description': 'Minor conference underdog with 4+ point ESPN edge'
        },
        {
            'name': 'November All Favorites',
            'conference': 'ALL',
            'min_edge': 3,
            'direction': 'FAVORITE',
            'description': 'All conferences favorite with 3+ point ESPN edge'
        }
    ],
    12: [  # December
        {
            'name': 'December Mid-Major Both',
            'conference': 'Mid-Major',
            'min_edge': 3,
            'direction': 'BOTH',
            'description': 'Mid-Major conference with 3+ point ESPN edge (either direction)'
        },
        {
            'name': 'December Minor Both',
            'conference': 'Minor',
            'min_edge': 3,
            'direction': 'BOTH',
            'description': 'Minor conference with 3+ point ESPN edge (either direction)'
        }
    ],
    1: [],  # January - AVOID
    2: [],  # February - AVOID
    3: [  # March
        {
            'name': 'March All Underdogs',
            'conference': 'ALL',
            'min_edge': 4,
            'direction': 'UNDERDOG',
            'description': 'All conferences underdog with 4+ point ESPN edge'
        }
    ],
    4: [  # April (March Madness extends)
        {
            'name': 'April Tournament Underdogs',
            'conference': 'ALL',
            'min_edge': 4,
            'direction': 'UNDERDOG',
            'description': 'Tournament underdog with 4+ point ESPN edge'
        }
    ]
}


def get_team_conference_type(team_name, teams_db):
    """
    Look up team's conference type from database

    Args:
        team_name: Team name to lookup
        teams_db: Dict mapping team names to conference types

    Returns:
        'Major', 'Mid-Major', 'Minor', or 'Unknown'
    """
    # Try exact match first
    if team_name in teams_db:
        return teams_db[team_name]

    # Try case-insensitive match
    team_lower = team_name.lower()
    for db_team, conf_type in teams_db.items():
        if db_team.lower() == team_lower:
            return conf_type

    # Try partial match
    for db_team, conf_type in teams_db.items():
        if team_name in db_team or db_team in team_name:
            return conf_type

    return 'Unknown'


def calculate_edge(espn_spread, consensus_spread):
    """
    Calculate ESPN edge

    Args:
        espn_spread: ESPN's predicted spread (positive = home favored)
        consensus_spread: Bookmaker consensus spread (positive = home favored)

    Returns:
        ESPN edge (positive = ESPN favors underdog, negative = ESPN favors favorite)
    """
    if espn_spread is None or consensus_spread is None:
        return None

    # Edge = Consensus - ESPN
    # Positive edge means ESPN is less confident in favorite (favors underdog)
    # Negative edge means ESPN is more confident in favorite (favors favorite)
    return consensus_spread - espn_spread


def determine_direction(edge):
    """
    Determine if ESPN favors underdog or favorite

    Args:
        edge: ESPN edge value

    Returns:
        'UNDERDOG' if positive edge, 'FAVORITE' if negative edge
    """
    if edge is None:
        return None

    return 'UNDERDOG' if edge > 0 else 'FAVORITE'


def apply_strategies(game_data, teams_db, current_month=None):
    """
    Apply monthly strategies to game data

    Args:
        game_data: Dict with game info including:
            - home_team, away_team
            - espn_spread, consensus_spread
            - edge
        teams_db: Dict mapping team names to conference types
        current_month: Month number (1-12), defaults to current month

    Returns:
        List of dicts with matching strategies and recommendations
    """
    if current_month is None:
        current_month = datetime.now().month

    strategies = STRATEGIES.get(current_month, [])

    if not strategies:
        return []  # No strategies for this month (e.g., January/February)

    matches = []

    # Get conference types
    home_conf = get_team_conference_type(game_data['home_team'], teams_db)
    away_conf = get_team_conference_type(game_data['away_team'], teams_db)

    # Calculate edge
    edge = calculate_edge(game_data.get('espn_spread'), game_data.get('consensus_spread'))

    if edge is None:
        return []

    edge_magnitude = abs(edge)
    edge_direction = determine_direction(edge)

    # Check each strategy
    for strategy in strategies:
        # Check minimum edge
        if edge_magnitude < strategy['min_edge']:
            continue

        # Check direction
        if strategy['direction'] != 'BOTH' and strategy['direction'] != edge_direction:
            continue

        # Check conference (use home team's conference for now)
        if strategy['conference'] != 'ALL' and strategy['conference'] != home_conf:
            continue

        # This game matches the strategy!
        # Determine bet recommendation
        bet_recommendation = generate_bet_recommendation(
            game_data, edge, edge_direction, strategy
        )

        matches.append({
            'strategy_name': strategy['name'],
            'strategy_description': strategy['description'],
            'edge': edge,
            'edge_magnitude': edge_magnitude,
            'edge_direction': edge_direction,
            'home_conference': home_conf,
            'away_conference': away_conf,
            'bet_recommendation': bet_recommendation
        })

    return matches


def generate_bet_recommendation(game_data, edge, edge_direction, strategy):
    """
    Generate human-readable bet recommendation

    Args:
        game_data: Game info dict
        edge: ESPN edge value
        edge_direction: 'UNDERDOG' or 'FAVORITE'
        strategy: Strategy dict

    Returns:
        String with bet recommendation
    """
    home_team = game_data['home_team']
    away_team = game_data['away_team']
    consensus = game_data.get('consensus_spread', 0)

    # Determine who is favorite/underdog based on consensus spread
    if consensus > 0:
        # Home team favored
        favorite = home_team
        underdog = away_team
        fav_spread = abs(consensus)
        dog_spread = abs(consensus)
    elif consensus < 0:
        # Away team favored
        favorite = away_team
        underdog = home_team
        fav_spread = abs(consensus)
        dog_spread = abs(consensus)
    else:
        # Pick'em
        return f"Pick'em: {away_team} @ {home_team}"

    # Generate recommendation based on edge direction
    if edge_direction == 'UNDERDOG':
        return f"Bet {underdog} +{dog_spread:.1f} (ESPN favors underdog with {abs(edge):.1f} pt edge)"
    else:  # FAVORITE
        return f"Bet {favorite} -{fav_spread:.1f} (ESPN favors favorite with {abs(edge):.1f} pt edge)"


if __name__ == '__main__':
    # Test with sample data
    teams_db = {
        'Duke': 'Major',
        'Auburn': 'Major',
        'Gonzaga': 'Mid-Major',
        'San Diego State': 'Mid-Major',
        'Vermont': 'Minor',
        'Jacksonville State': 'Minor',
    }

    sample_game = {
        'home_team': 'Duke',
        'away_team': 'Vermont',
        'espn_spread': 15.0,  # Duke favored by 15
        'consensus_spread': 18.0,  # Duke favored by 18
    }

    matches = apply_strategies(sample_game, teams_db, current_month=11)

    print(f"Game: {sample_game['away_team']} @ {sample_game['home_team']}")
    print(f"ESPN Spread: {sample_game['espn_spread']}")
    print(f"Consensus Spread: {sample_game['consensus_spread']}")
    print(f"\nMatching Strategies: {len(matches)}")

    for match in matches:
        print(f"\n  Strategy: {match['strategy_name']}")
        print(f"  Edge: {match['edge']:.1f} ({match['edge_direction']})")
        print(f"  Recommendation: {match['bet_recommendation']}")
