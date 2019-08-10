module SmartPlayTest

using  Test

import Cribbage
import Cribbage.SmartPlay: SmartPlayer
import Cribbage.TwoPlayer
import Cribbage.ThreePlayer
import Cribbage.FourPlayer

@testset "Smart Players" begin
    p₁ = SmartPlayer("one")
    @test p₁.name == "one"
    p₂ = SmartPlayer("two")
    @test p₂.name == "two"
    @test p₁ ≠ p₂
end

@testset "Smart Gameplay" begin

    # Logging.with_logger(logger) do
        p₁ = SmartPlayer("player one")
        p₂ = SmartPlayer("player two")
        game = Cribbage.TwoPlayer.TwoPlayerGame(p₁, p₂)
        gamestate = Cribbage.TwoPlayer.TwoPlayerGameState(
            game, rand([p₁, p₂])
        )

        gamestates = Cribbage.playgame(gamestate)

        p₃ = SmartPlayer("player three")
        game = Cribbage.ThreePlayer.ThreePlayerGame(p₁, p₂, p₃)
        gamestate = Cribbage.ThreePlayer.ThreePlayerGameState(
            game, rand([p₁, p₂, p₃])
        )
        gamestates = Cribbage.playgame(gamestate)

        p₄ = SmartPlayer("player four")
        game = Cribbage.FourPlayer.FourPlayerGame(p₁, p₂, p₃, p₄)
        gamestate = Cribbage.FourPlayer.FourPlayerGameState(
            game, rand([p₁, p₂, p₃, p₄])
        )
        gamestates = Cribbage.playgame(gamestate)
    # end

end

end  # module SmartPlayTest
