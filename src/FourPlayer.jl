module FourPlayer

import Cribbage: CribbageGame, GameState, Player, nextplayer, UnexpectedPlayerException
import Cribbage.TwoPlayer: incrementscore, numplayers, cardsdealt, cardstocrib, players, reportscore, isgameover, rotatedealer

export incrementscore, isgameover, players, reportscore, rotatedealer, FourPlayerGame, FourPlayerGameState

struct FourPlayerGame <: CribbageGame
    p₁ :: Player
    p₂ :: Player
    p₃ :: Player
    p₄ :: Player
    winningscore :: Int8
    function FourPlayerGame(
        p₁::Player, p₂::Player, p₃::Player, p₄::Player, winningscore::Integer=121)
        @assert(winningscore == 121 || winningscore == 61, "winningscore is either 61 or 121")
        @assert(p₁ ≢ p₂)
        @assert(p₁ ≢ p₃)
        @assert(p₁ ≢ p₄)
        @assert(p₂ ≢ p₃)
        @assert(p₂ ≢ p₄)
        @assert(p₃ ≢ p₄)
        new(p₁, p₂, p₃, p₄, winningscore)
    end
end

struct FourPlayerGameState <: GameState
    game :: FourPlayerGame
    dealer :: Player
    s₁ :: Int8
    s₂ :: Int8
    function FourPlayerGameState(
        game::FourPlayerGame, dealer::Player, s₁::Integer=0, s₂::Integer=0)
        @assert(dealer ∈ players(game), "dealer is not one of the players of the game")
        @assert(0 ≤ s₁ ≤ game.winningscore, "s₁ is an invalid score")
        @assert(0 ≤ s₂ ≤ game.winningscore, "s₂ is an invalid score")
        new(game, dealer, s₁, s₂)
    end
end

function numplayers(game::FourPlayerGame)::Int8
    return 4
end

function cardsdealt(game::FourPlayerGame)::Int8
    return 5
end

function cardstocrib(game::FourPlayerGame)::Int8
    return 0
end

function players(game::FourPlayerGame)::Array{Player,1}
    return [ game.p₁, game.p₂, game.p₃, game.p₄ ]
end

function incrementscore(
        gamestate::FourPlayerGameState,
        player::Player,
        amount::Integer
    )
    @assert(amount ≥ 0)
    if player === gamestate.game.p₁ || player === gamestate.game.p₃
        return FourPlayerGameState(
            gamestate.game,
            gamestate.dealer,
            min(gamestate.s₁ + amount, gamestate.game.winningscore),
            gamestate.s₂
        )
    elseif player === gamestate.game.p₂ || player === gamestate.game.p₄
        return FourPlayerGameState(
            gamestate.game,
            gamestate.dealer,
            gamestate.s₁,
            min(gamestate.s₂ + amount, gamestate.game.winningscore)
        )
    else
        throw(UnexpectedPlayerException("$(player.name) is not one of the players in this game"))
    end
end

function isgameover(gamestate::FourPlayerGameState)::Bool
    return gamestate.s₁ == gamestate.game.winningscore || gamestate.s₂ == gamestate.game.winningscore
end

function reportscore(gamestate::FourPlayerGameState)::String
    return "$(gamestate.s₁) - $(gamestate.s₂)"
end


function rotatedealer(gamestate::FourPlayerGameState)::FourPlayerGameState
    return FourPlayerGameState(
        gamestate.game,
        nextplayer(players(gamestate.game), gamestate.dealer),
        gamestate.s₁,
        gamestate.s₂
    )
end


end  # module FourPlayer
