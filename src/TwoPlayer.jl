"""
Module specifying the structure of a two-player cribbage game.

The code here represents the reference implementation for other versions of the
    game (e.g.: three-player, four-player).
"""
module TwoPlayer

import Cribbage: CribbageGame, GameState, Player, nextplayer, UnexpectedPlayerException

export incrementscore, isgameover, players, reportscore, rotatedealer, TwoPlayerGame, TwoPlayerGameState

struct TwoPlayerGame <: CribbageGame
    p₁ :: Player
    p₂ :: Player
    winningscore :: Int8
    function TwoPlayerGame(
        p₁::Player, p₂::Player, winningscore::Integer=121)
        @assert(winningscore == 121 || winningscore == 61, "winningscore is either 61 or 121")
        @assert(p₁ ≢ p₂)
        new(p₁, p₂, winningscore)
    end
end

struct TwoPlayerGameState <: GameState
    game :: TwoPlayerGame
    dealer :: Player
    s₁ :: Int8
    s₂ :: Int8
    function TwoPlayerGameState(
        game::TwoPlayerGame, dealer::Player, s₁::Integer=0, s₂::Integer=0)
        @assert(dealer ∈ players(game), "dealer is not one of the players of the game")
        @assert(0 ≤ s₁ ≤ game.winningscore, "s₁ is an invalid score")
        @assert(0 ≤ s₂ ≤ game.winningscore, "s₂ is an invalid score")
        new(game, dealer, s₁, s₂)
    end
end

"""
    numplayers(game)
Returns the number of players in `game`.
"""
function numplayers(game::TwoPlayerGame)::Int8
    return 2
end

"""
    cardsdealt(game)
Returns the number of cards to be dealt to each player in `game`.
"""
function cardsdealt(game::TwoPlayerGame)::Int8
    return 6
end

"""
    cardstocrib(game)
Returns the number of cards to seed the crib with during each hand of `game`.
"""
function cardstocrib(game::TwoPlayerGame)::Int8
    return 0
end

"""
    players(game)
Returns an array of players in `game`.
"""
function players(game::TwoPlayerGame)::Array{Player,1}
    return [ game.p₁, game.p₂ ]
end

"""
    incrementscore(gamestate, player, amount)
Returns a new game state, starting from `gamestate`, in which the score for
    `player` has been incremented by `amount`.
"""
function incrementscore(
        gamestate::TwoPlayerGameState,
        player::Player,
        amount::Integer
    )
    @assert(amount ≥ 0)
    @debug "Incrementing the score for $(player.name) by $(amount)"
    if player === gamestate.game.p₁
        return TwoPlayerGameState(
            gamestate.game,
            gamestate.dealer,
            min(gamestate.s₁ + amount, gamestate.game.winningscore),
            gamestate.s₂
        )
    elseif player === gamestate.game.p₂
        return TwoPlayerGameState(
            gamestate.game,
            gamestate.dealer,
            gamestate.s₁,
            min(gamestate.s₂ + amount, gamestate.game.winningscore)
        )
    else
        throw(UnexpectedPlayerException("$(player.name) is not one of the players in this game"))
    end
end

"""
    isgameover(gamestate)
Returns true if any player has a winning score in `gamestate`.
"""
function isgameover(gamestate::TwoPlayerGameState)::Bool
    return gamestate.s₁ == gamestate.game.winningscore || gamestate.s₂ == gamestate.game.winningscore
end

"""
    reportscore(gamestate)
Returns a string representing the score in `gamestate`.
"""
function reportscore(gamestate::TwoPlayerGameState)::String
    return "$(gamestate.s₁) - $(gamestate.s₂)"
end

"""
    rotatedealer(gamestate)
Returns a new game state with the next dealer selected.
"""
function rotatedealer(gamestate::TwoPlayerGameState)::TwoPlayerGameState
    return TwoPlayerGameState(
        gamestate.game,
        nextplayer(players(gamestate.game), gamestate.dealer),
        gamestate.s₁,
        gamestate.s₂
    )
end

end  # module TwoPlayer
