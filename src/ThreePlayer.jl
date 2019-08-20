module ThreePlayer

import Cribbage: CribbageGame, GameState, Player, nextplayer, UnexpectedPlayerException
import Cribbage.TwoPlayer: incrementscore, numplayers, cardsdealt, cardstocrib, players, reportscore, cardstocrib, isgameover, rotatedealer

export incrementscore, isgameover, players, reportscore, rotatedealer, ThreePlayerGame, ThreePlayerGameState

struct ThreePlayerGame <: CribbageGame
    p₁ :: Player
    p₂ :: Player
    p₃ :: Player
    winningscore :: Int8
    function ThreePlayerGame(
        p₁::Player, p₂::Player, p₃::Player, winningscore::Integer=121)
        @assert(winningscore == 121 || winningscore == 61, "winningscore is either 61 or 121")
        @assert(p₁ ≢ p₂)
        @assert(p₁ ≢ p₃)
        @assert(p₂ ≢ p₃)
        new(p₁, p₂, p₃, winningscore)
    end
end

struct ThreePlayerGameState <: GameState
    game :: ThreePlayerGame
    dealer :: Player
    s₁ :: Int8
    s₂ :: Int8
    s₃ :: Int8
    function ThreePlayerGameState(
            game::ThreePlayerGame,
            dealer::Player,
            s₁::Integer=0,
            s₂::Integer=0,
            s₃::Integer=0
        )
        @assert(dealer ∈ players(game), "dealer is not one of the players of the game")
        @assert(0 ≤ s₁ ≤ game.winningscore, "s₁ is an invalid score")
        @assert(0 ≤ s₂ ≤ game.winningscore, "s₂ is an invalid score")
        @assert(0 ≤ s₃ ≤ game.winningscore, "s₃ is an invalid score")
        new(game, dealer, s₁, s₂, s₃)
    end
end


function numplayers(game::ThreePlayerGame)::Int8
    return 3
end

function cardsdealt(game::ThreePlayerGame)::Int8
    return 5
end

function cardstocrib(game::ThreePlayerGame)::Int8
    return 1
end

function players(game::ThreePlayerGame)::Array{Player,1}
    return [ game.p₁, game.p₂, game.p₃ ]
end

function incrementscore(gamestate::ThreePlayerGameState, player::Player, amount::Integer)
    @assert(amount ≥ 0)
    if player === gamestate.game.p₁
        return ThreePlayerGameState(
            gamestate.game,
            gamestate.dealer,
            min(gamestate.s₁ + amount, gamestate.game.winningscore),
            gamestate.s₂,
            gamestate.s₃
        )
    elseif player === gamestate.game.p₂
        return ThreePlayerGameState(
            gamestate.game,
            gamestate.dealer,
            gamestate.s₁,
            min(gamestate.s₂ + amount, gamestate.game.winningscore),
            gamestate.s₃
        )
    elseif player === gamestate.game.p₃
        return ThreePlayerGameState(
            gamestate.game,
            gamestate.dealer,
            gamestate.s₁,
            gamestate.s₂,
            min(gamestate.s₃ + amount, gamestate.game.winningscore)
        )
    else
        throw(UnexpectedPlayerException("$(player.name) is not one of the players in this game"))
    end
end

function isgameover(gamestate::ThreePlayerGameState)::Bool
    return (
        gamestate.s₁ == gamestate.game.winningscore ||
        gamestate.s₂ == gamestate.game.winningscore ||
        gamestate.s₃ == gamestate.game.winningscore
    )
end

function reportscore(gamestate::ThreePlayerGameState)::String
    return "$(gamestate.s₁) - $(gamestate.s₂) - $(gamestate.s₃)"
end

function rotatedealer(gamestate::ThreePlayerGameState)::ThreePlayerGameState
    return ThreePlayerGameState(
        gamestate.game,
        nextplayer(players(gamestate.game), gamestate.dealer),
        gamestate.s₁,
        gamestate.s₂,
        gamestate.s₃
    )
end


end  # module ThreePlayer
