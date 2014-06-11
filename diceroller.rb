# Edge of the Empire Dice Probability Calculator.
# Calculate the Probability of a given dice set
# - Nik Aleliunas

# Dice symbol key:
# (S)uccess, (A)dvantage, (F)ailure), (T)hreat, t(R)iumph, (D)espair
boost =       [nil, nil, 'S',  'SA', 'AA', 'A']
setback =     [nil, nil, 'F',  'F',  'T',  'T']
ability =     [nil, 'S', 'S',  'SS', 'A',  'A', 'SA', 'AA']
difficulty =  [nil, 'F', 'FF', 'T',  'T',  'T', 'TT', 'FT']
proficiency = [nil, 'S', 'S',  'SS', 'SS', 'A', 'SA', 'SA', 'SA', 'AA', 'AA', 'SR']
challenge =   [nil, 'F', 'F',  'FF', 'FF', 'T', 'T',  'FT', 'FT', 'TT', 'TT', 'FD']
dice_string = nil # Input String of dice pool. Should consist of BSADPC's.

while ARGV.length > 0
  dice_string = ARGV.shift.upcase
end

if dice_string.nil?
  puts 'Dice Pool: (Use the first letter to signify a die: B,S,A,D,P or C.)'
  STDOUT.flush
  dice_string = gets.chomp.upcase
end


# count the number of each type of die input
boost_num       = dice_string.count 'B'
setback_num     = dice_string.count 'S'
ability_num     = dice_string.count 'A'
difficulty_num  = dice_string.count 'D'
proficiency_num = dice_string.count 'P'
challenge_num   = dice_string.count 'C'

dice_string = 'P' * proficiency_num + 'A' * ability_num + \
'C' * challenge_num + 'D' * difficulty_num + \
'B' * boost_num + 'S' * setback_num
# Create the number of possibilities. (sides on die)^(# of dice)
possibilities_max = 6**(boost_num + setback_num) * 8**(ability_num + difficulty_num) * 12**(proficiency_num + challenge_num)

if (possibilities_max <= 1)
  p '+++ OUT OF CHESE ERROR REDO FROM START +++'
  exit
end

# create die grid
die_grid = []

# populate die grid with the input dice
boost_num.times       { die_grid << boost       }
setback_num.times     { die_grid << setback     }
ability_num.times     { die_grid << ability     }
difficulty_num.times  { die_grid << difficulty  }
proficiency_num.times { die_grid << proficiency }
challenge_num.times   { die_grid << challenge   }

dice_roll = die_grid.shift.product(*die_grid)[rand(possibilities_max)].join()

roll_success = dice_roll.count('S') - dice_roll.count('F')
roll_advantage = dice_roll.count('A') - dice_roll.count('T')
roll_triumph = dice_roll.count('R')
roll_despair = dice_roll.count('D')
p "+++ Results of Roll: #{dice_string} +++"
puts roll_success >= 0 ? "Success: #{roll_success}".center(25 + dice_string.length) : "Failure: #{roll_success.abs}".center(25 + dice_string.length)
puts roll_advantage >= 0 ? "Advantage: #{roll_advantage}".center(25 + dice_string.length) : "Threat: #{roll_advantage.abs}".center(25 + dice_string.length)
puts "Triumph: #{roll_triumph}".center(25 + dice_string.length) if roll_triumph > 0
puts "Despair: #{roll_despair}".center(25 + dice_string.length) if roll_despair > 0
p '+' * (25 + dice_string.length)
