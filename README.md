EotE-Dice-Probability
=====================

A probability generator and die roller for the dice of Fantasy Flight's RPG Edge of the Empire

Dice Probability:
  To use this tool, you can input a series of dice at command line, or, if left empty, when prompted during run time. 
  The Dice are as follows:

    (B)oost
    (S)etback
    (A)bility
    (D)Difficulty
    (P)roficency
    (C)hallenge

Just input any series of those letters, and the program will output the probability of that pool, as well as the probability of every possibility of symbols it can get. Note that Triumph and Despair are not counted in these probabilities, as they would make the already sparse larger pools even sparser.

Command line Arguments:

    -X : eXpanded. Show the Total Probabilities
    -C : Combination. Show every single roll possibility.
    -T:[S,A,F,T] : Target. Input the target you want to hit (SST = 2 success, 1 Threat), and the program will tell you the probability of getting higher than that. If the area after -T is left blank, you may input your target during run time.

Dice Roller:
  A roller for the EotE dice. Input dice as you would for the Dice Probability, and it will give you a random roll of that pool.
