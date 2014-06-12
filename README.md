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
  A roller for the EotE dice. Input dice as you would for the Dice Probability, and it will give you a random roll of that pool.
  
Explanation of result grid:
 The 1st Dimension is Success, Failure. [0-Max Success] here means that many successes.
 The other half of the 1st dimension is the amount of Failures, in such a way that the probability of the 1st failure is the last index in the array, such that: (Max Success + 1) Maps Yo (Max Failures) and (result_grid.max) Maps To (1 Failure)
 For example, for 4 successes, 2 failures, a row would look like this: [0S, 1S, 2S, 3S, 4S, 2F, 1F]
 The 2nd Dimension works the same way for Advantage/Threat.
 The 3rd and 4th dimensions are normal, 0-Max for Triumph and Despair, respectively.
 Quite simple.
