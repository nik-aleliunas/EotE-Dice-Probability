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

Just input any series of those letters (read: /[BSADPC]*/), and the program will output the probability of that pool, as well as the probability of every possibility of symbols it can get.
Command line Arguments:

    -X : eXpanded. Show the Total Probabilities
    -C : Combination. Show every single roll possibility.
    -T:/[SAFTRD]*/ : Target. Input the target you want to hit (SST = 2 success, 1 Threat), and the program will tell you the probability of getting higher than that. If the area after -T is left blank, you may input your target during run time.
    -D:/[BSADPC]*/ : Run time Dice Pool.

Dice Roller:
  A roller for the EotE dice. Input a dice pool string at either run time or when the script promts to, and it wil lreturn a random roll for that pool. Pools are of the form /[BSADPC]*/.
