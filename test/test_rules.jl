module TestRules

using  Test
import PlayingCards: Card
import Cribbage.Rules: cardvalue, validhands, validplays

@testset "Test cardvalue" begin

    @test cardvalue(Card("5♥")) == 5
    @test cardvalue(Card("A♠")) == 1
    @test cardvalue(Card("10♣")) == 10
    @test cardvalue(Card("J♦")) == 10
    @test cardvalue(Card("Q♥")) == 10
    @test cardvalue(Card("K♦")) == 10

end

@testset "Test validhands" begin

    originalhand = tuple(
        Card("5♥"), Card("A♠"), Card("10♣"), Card("J♦"), Card("Q♥")
    )
    hands = validhands(originalhand)
    @test length(hands) == 5
    for hand in hands
        @test length(hand) == 4
        for card in hand
            @test card ∈ originalhand
        end
    end

    originalhand = tuple(
        Card("5♥"), Card("A♠"), Card("10♣"), Card("J♦"), Card("Q♥"), Card("K♦")
    )
    hands = validhands(originalhand)
    @test length(hands) == 15
    for hand in hands
        @test length(hand) == 4
        for card in hand
            @test card ∈ originalhand
        end
    end
end

@testset "Test validplays" begin

    prior = tuple()
    hand = tuple(
        Card("5♥"), Card("10♣"), Card("J♦"), Card("Q♥")
    )
    possibleplays = validplays(prior, hand)
    @test length(possibleplays) == 4
    for card in possibleplays
        @test card ∈ hand
    end

    prior = tuple(Card("5♥"), Card("K♦"))
    hand = tuple(
        Card("10♣"), Card("J♦"), Card("Q♥")
    )
    possibleplays = validplays(prior, hand)
    @test length(possibleplays) == 3
    for card in possibleplays
        @test card ∈ hand
    end

    prior = tuple(Card("5♥"), Card("K♦"), Card("10♣"), Card("4♣"))
    hand = tuple(
        Card("J♦"), Card("Q♥")
    )
    possibleplays = validplays(prior, hand)
    @test length(possibleplays) == 0

    prior = tuple(Card("5♥"), Card("K♦"), Card("10♣"), Card("4♣"))
    hand = tuple()
    possibleplays = validplays(prior, hand)
    @test length(possibleplays) == 0
end

end  # module TestRules
