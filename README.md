EotE-Dice-Probability
=====================

A probability generator for the dice of Fantasy Flight's RPG Edge of the Empire

To use this tool, you can input a series of dice at command line, or, if left empty, when prompted. 
The Dice are as follows:

(B)oost

(S)etback

(A)bility

(D)Difficulty

(P)roficency

(C)hallenge

Just input any series of those letters, and the program will output the probability of that pool.

Command line Arguments:

-S : Simplified. Shows only the Success, Advantage & Threat Probabilities, instead of every single probability.

-C : Combination. Shows every single combination of the dice pool, one combination per line. (Hint: at 2 dice, this is 36+ lines. Be warned.)

TODO:

-T:[S,A] : Target. Input the amount of success and advantage you want to hit, and the program will tell you the probability of getting higher than that.
