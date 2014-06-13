# Edge of the Empire Dice Probability Calculator.
# Calculate the Probability of a given dice set
# - Nik Aleliunas

# Dice key:
# (B)oost, (S)etback, (A)bility, (D)ifficulty, (P)roficiency, (C)hallenge

# Dice symbol key:
# (S)uccess, (A)dvantage, (F)ailure), (T)hreat, t(R)iumph, (D)espair
$boost =       [nil, nil, 'S',  'SA', 'AA', 'A']
$setback =     [nil, nil, 'F',  'F',  'T',  'T']
$ability =     [nil, 'S', 'S',  'SS', 'A',  'A', 'SA', 'AA']
$difficulty =  [nil, 'F', 'FF', 'T',  'T',  'T', 'TT', 'FT']
$proficiency = [nil, 'S', 'S',  'SS', 'SS', 'A', 'SA', 'SA', 'SA', 'AA', 'AA', 'SR']
$challenge =   [nil, 'F', 'F',  'FF', 'FF', 'T', 'T',  'FT', 'FT', 'TT', 'TT', 'FD']
$standard_round = 2
expanded_toggle = false # expanded output toggle
combinations_toggle = false # Show all dice combinations Toggle
target_toggle = false # Target probability computation toggle
group_target_toggle = false # Target probability computation toggle

# Description : Create and populate a grid with the probabilities of this dice pool
# Input :
# dice_string : string that represents a dice pool
# Output:
# result_grid : See Readme.
def calculate_probability_grid (dice_string = 'B')
  
  # Create two grids, one for bad dice and one for good dice. these will be the "starting probabilities"
  success_temp, advantage_temp, failure_temp, threat_temp, despair_temp, triumph_temp = 1, 1, 1, 1, 1, 1
  bad_grid = Array.new(failure_temp) { Array.new(threat_temp) { Array.new(triumph_temp) { Array.new(despair_temp, 1.0) } } }
  good_grid = Array.new(success_temp) { Array.new(advantage_temp) { Array.new(triumph_temp) { Array.new(despair_temp, 1.0) } } }
  
  #Iterate through the dice string, and add good dice to the good probability grid and bad to the bad probability grid
  dice_string.each_char do |die|
    #First, what die is it?
    temp_die = []
    case die
    when 'B'
      temp_die = $boost
      success_temp   += 1
      advantage_temp += 2
      possibilities = 6
      temp_die_grid = Array.new(2) { Array.new(3) { Array.new(1) { Array.new(1, 0.0) } } }
    when 'S'
      temp_die = $setback
      failure_temp += 1
      threat_temp  += 1
      possibilities = 6
      temp_die_grid = Array.new(2) { Array.new(2) { Array.new(1) { Array.new(1, 0.0) } } }
    when 'A'
      temp_die = $ability
      success_temp   += 2
      advantage_temp += 2
      possibilities = 8
    when 'D'
      temp_die = $difficulty
      failure_temp += 2
      threat_temp  += 2
      possibilities = 8
    when 'P'
      temp_die = $proficiency
      success_temp   += 2
      advantage_temp += 2
      triumph_temp += 1
      possibilities = 12
      temp_die_grid = Array.new(3) { Array.new(3) { Array.new(2) { Array.new(1, 0.0) } } }
    when 'C'
      temp_die = $challenge
      failure_temp += 2
      threat_temp  += 2
      despair_temp += 1
      possibilities = 12
      temp_die_grid = Array.new(3) { Array.new(3) { Array.new(1) { Array.new(2, 0.0) } } }
    end
    temp_die_grid = Array.new(3) { Array.new(3) { Array.new(1) { Array.new(1, 0.0) } } } if /[^BSPC]/ === die
    # What are all the possible symbol sets it can land on?
    # How many times will it land on that symbol set?
    temp_die.each do |side|
      success_count = side.nil? ? 0 : side.scan(/[SF]/).length
      advantage_count = side.nil? ? 0 : side.scan(/[AT]/).length
      triumph_count = side.nil? ? 0 : side.scan('R').length
      despair_count = side.nil? ? 0 : side.scan('D').length
      temp_die_grid[success_count][advantage_count][triumph_count][despair_count] += 1
    end
    
    # Take the symbol set distribution and make it into probability
    temp_die_grid.each { |x| x.each { |y| y.each { |z| z.map! { |n| n / possibilities } } } }
    
    # Combine those probabilities with the probabilites of the dice that came before
    case die
    when /[BAP]/
      good_grid = populate_probability_grid good_grid, temp_die_grid
    when /[SDC]/
      bad_grid = populate_probability_grid bad_grid, temp_die_grid
    end
  end
  
  # After you combine all the good dice and all the bad dice, combine those both together into a larger grid.
  
  # Find the maximum number of symbols for the specified dice set.
  success_max, advantage_max, threat_max, failure_max, triumph_max, despair_max = dice_string_interpolation dice_string
  # create a result grid off those ranges.
  result_grid = Array.new(success_max + failure_max + 1) \
  { Array.new(advantage_max + threat_max + 1) { Array.new(triumph_max + 1) { Array.new(despair_max + 1, 0.0) } } }
  
  0.upto(success_temp - 1) do |i|
    0.upto(advantage_temp - 1) do |j|
      0.upto(triumph_temp - 1) do |k|
        0.upto(failure_temp - 1) do |l|
          0.upto(threat_temp - 1) do |m|
            0.upto(despair_temp - 1) do |n|
              # i is successes, m is failures. That means the absolute value of a negative index is the failure index. Same with threat.
              result_grid[i - l][j - m][k][n] += good_grid[i][j][k][0] * bad_grid[l][m][n][0]
            end
          end
        end
      end
    end
  end
  # Now multiply the probabilities so they are out of 100 instead of 1.
  return result_grid.each { |x| x.each { |y| y.each { |z| z.map! { |n| n * 100 } } } }
end

# Find the maximum number of symbols for a specified dice set
# Output:
# symbol_maximum_values : The maximum range of success/failure, advantage/threat & despair and triumph.
def dice_string_interpolation (dice_string)
  symbol_maximum_values = Array.new(6, 0)
  
  proficiency_num = dice_string.count 'P'
  ability_num     = dice_string.count 'A'
  challenge_num   = dice_string.count 'C'
  difficulty_num  = dice_string.count 'D'
  boost_num       = dice_string.count 'B'
  setback_num     = dice_string.count 'S'
  
  
  # calculate the maximum range of success/failure & advantage/threat.
  # this will give us a length for each dimension of result_grid. See readme for more details.
  # Most die have a side with 2 of each symbol, except advantage and setback die.
  # 0 = Success
  # 1 = Advantage
  # 2 = Threat
  # 3 = Failure
  # 4 = Proficinecy
  # 5 = Despair
  symbol_maximum_values[0] = boost_num + 2 * (ability_num + proficiency_num)
  symbol_maximum_values[1] =  2 * (boost_num + ability_num + proficiency_num)
  symbol_maximum_values[2] = setback_num + 2 * (difficulty_num + challenge_num)
  symbol_maximum_values[3] = setback_num + 2 * (difficulty_num + challenge_num)
  symbol_maximum_values[4] = proficiency_num
  symbol_maximum_values[5] = challenge_num
  return symbol_maximum_values
end

# Take two 4D grids, and combined their probabilites together. Think of them like dice.
# Input: the two grids
# Output: A Larger, more shiny grid.
# Note: since this is for grids without result_grid's ridiculous reverse indecies \
# dice_string isn't needed, since you're iterating through the WHOLE grid in one loop structure. So much simpler.
def populate_probability_grid (grid1, grid2)
  # x,y,z,w are the maximum ranges of each set of symbol pairs.
  # When you add the maximum symbols of 1 to the maximum symbols of 2
  # you only over lap at where they're both 0.
  # Maximum Success/Failure
  x = grid1.length + grid2.length - 1
  # Maximum Advantage/Threat
  y = grid1[0].length + grid2[0].length - 1
  # Maximum Triumph
  z = grid1[0][0].length + grid2[0][0].length - 1
  # Maximum Despair
  w = grid1[0][0][0].length + grid2[0][0][0].length - 1
  
  #Make a grid that is large enoguh to fit grid1 x grid2
  result_grid = Array.new(x) { Array.new(y) { Array.new(z) { Array.new(w, 0.0) } } }
  # populate!
  # Is iterating over integers faster than over indexes? Probably!
  0.upto(grid1.length - 1) do |i|
    0.upto(grid1[0].length - 1) do |j|
      0.upto(grid1[0][0].length - 1) do |k|
        0.upto(grid1[0][0][0].length - 1) do |l|
          0.upto(grid2.length - 1) do |m|
            0.upto(grid2[0].length - 1) do |n|
              0.upto(grid2[0][0].length - 1) do |o|
                0.upto(grid2[0][0][0].length - 1) do |p|
                  result_grid[i + m][j + n][k + o][l + p] += grid1[i][j][k][l] * grid2[m][n][o][p]
                end
              end
            end
          end
        end
      end
    end
  end
  return result_grid
end

# Combinations.
# Prints every permutation of given dice pool
# Note that this is REALLY BLOODY SLOW. Seriously, it's ~12^x Combonations
def print_combination (dice_string)
  
  proficiency_num = dice_string.count 'P'
  ability_num     = dice_string.count 'A'
  challenge_num   = dice_string.count 'C'
  difficulty_num  = dice_string.count 'D'
  boost_num       = dice_string.count 'B'
  setback_num     = dice_string.count 'S'
  
  die_grid = []
  # populate die grid with the input dice
  boost_num.times       { die_grid << boost     }
  setback_num.times     { die_grid << setback   }
  ability_num.times     { die_grid << ability   }
  difficulty_num.times  { die_grid << difficulty  }
  proficiency_num.times { die_grid << proficiency }
  challenge_num.times   { die_grid << challenge   }
    
  die_grid.shift.product(*die_grid) { |combi| p combi }
end

# print a cell from a result grid,
# Input:
# s_or_f, a_or_t : two Strings Signifying which portion of the result grid you're in
# probability : self explanatory
# (i,j,k,l) : The number of symbols for each of Success/Failure, Advantage/Threat, Triumph & Despair
def print_probability (s_or_f = 'Success', a_or_t = 'Advantage', probability = 0, i = 0, j = 0, k = 0, l = 0)
  probability = probability.round($standard_round)
  puts  case k
        when 0
          case l
          when 0
            "#{i} #{s_or_f} & #{j} #{a_or_t}: #{probability}%"
          else
            "#{i} #{s_or_f},  #{j} #{a_or_t} & #{l} Despair: #{probability}%"
          end
        else
          case l
          when 0
            "#{i} #{s_or_f} & #{j} #{a_or_t} & #{k} Triumph: #{probability}%"
          else
            "#{i} #{s_or_f},  #{j} #{a_or_t},  #{k} Triumph & #{l} Despair: #{probability}%"
          end
        end
end

# Description: Calculates the probability of reaching/passing a certain target, signified by target_string.
# Inputs :
# result_grid : stores all the probabilities of all the different possibilities. Failure and Threat start at negative indicies and count towards center.
# target_string : string that represents the target success/failure threshhold
# dice_string : string that represents the dice pool. Required for splitting the result_grid into correct quadrants.
# Output : Target Probability, as a percentage 0.0 - 100.0%
def target_calculation (result_grid, target_string = '', dice_string)
  #Find the starting point for iterating over the grid arrays: the point where the target has been met
  target_success   = target_string.count('S') - target_string.count('F')
  target_advantage = target_string.count('A') - target_string.count('T')
  # Failure and threat: Since you have to deal with 0 F/T targets as well as higher,
  # the failure target might have to chance, since 0-1 is -1 and that's terrible.
  target_failure = (0 > (target_success.abs - 1) ? 0 : (target_success.abs - 1))
  target_threat = (0 > (target_advantage.abs - 1) ? 0 : (target_advantage.abs - 1))
  target_triumph = target_string.count('R')
  target_despair = target_string.count('D')
  
  success_max, advantage_max, threat_max, failure_max, triumph_max, despair_max = dice_string_interpolation dice_string
  target_probability = 0
  
  if target_success >= 0
    result_grid[target_success..success_max].each do |result_success_line|
      if target_advantage >= 0
        result_success_line[target_advantage..advantage_max].each do |result_advantage_line|
          result_advantage_line[target_triumph..triumph_max].each do |result_triumph_line|
            result_triumph_line[target_despair..despair_max].each do |result_cell|
              #Success, Advantage Probability
              target_probability += result_cell
            end
          end
        end
      end
      # To make sure you don't double dip
      next if (threat_max == 0)
      if target_advantage <= 0
        result_success_line.reverse[target_threat..threat_max - 1].each do |result_threat_line|
          result_threat_line[target_triumph..triumph_max].each do |result_triumph_line|
            result_triumph_line[target_despair..despair_max].each do |result_cell|
              #Success, Threat Probability
              target_probability += result_cell
            end
          end
        end
      end
    end
  end
  if target_success <= 0
    result_grid.reverse[target_failure..failure_max - 1].each do |result_failure_line|
      # Making sure you don't double dip: Failure Version! Fence Posting.
      break if failure_max == 0
      if target_advantage >= 0
        result_failure_line[target_advantage..advantage_max].each do |result_advantage_line|
          result_advantage_line[target_triumph..triumph_max].each do |result_triumph_line|
            result_triumph_line[target_despair..despair_max].each do |result_cell|
                target_probability += result_cell
            end
          end
        end
      end
      # Threat
      next if threat_max == 0
      if target_advantage <= 0
        result_failure_line.reverse[target_threat..threat_max - 1].each do |result_threat_line|
          result_threat_line[target_triumph..triumph_max].each do |result_triumph_line|
            result_triumph_line[target_despair..despair_max].each do |result_cell|
                target_probability += result_cell
            end
          end
        end
      end
    end
  end
  return target_probability
end


# Description: Calculates the probability of reaching/passing a certain group of targets, signified by target_string.
# Inputs :
# result_grid : stores all the probabilities of all the different possibilities. Failure and Threat start at negative indicies and count towards center.
# t_string : string that represents the target success/failure threshhold
# d_string : string that represents the dice pool. Required for splitting the result_grid into correct quadrants.
# Output : Target Probability, as a percentage 0.0 - 100.0%
# Note: Only works for "positive" values. Will try to generify it, but that might be an issue.
def group_target_calculation (result_grid, t_string = '', d_string)
  t_strings_array = t_string.split(".")
  t_success_max, t_advantage_max, t_triumph_max, t_success_min, t_advantage_min, t_triumph_min = 0, 0, 0, 50, 50, 50
  
  # calculate the minimum and maximum targets for each symbol. the difference will be the range of our array.
  # The minimum where to start on the result grid, the maximum will tell us where to stop.
  # This is to compact the grid so we aren't iterating from 0-success_max, which is too much wasted effort and space.
  t_strings_array.each do |s|
    t_success_max   = s.count('S') > t_success_max   ? s.count('S') : t_success_max
    t_advantage_max = s.count('A') > t_advantage_max ? s.count('A') : t_advantage_max
    t_triumph_max   = s.count('R') > t_triumph_max   ? s.count('R') : t_triumph_max
    t_success_min   = s.count('S') < t_success_min   ? s.count('S') : t_success_min
    t_advantage_min = s.count('A') < t_advantage_min ? s.count('A') : t_advantage_min
    t_triumph_min   = s.count('R') < t_triumph_min   ? s.count('R') : t_triumph_min
  end
  # Create a gird for the target sucess rates.
  t_grid_x = t_success_max - t_success_min + 1
  t_grid_y = t_advantage_max - t_advantage_min + 1
  t_grid_z = t_triumph_max - t_triumph_min + 1
  t_grid = Array.new(t_grid_x) { Array.new(t_grid_y) { Array.new(t_grid_z, false) } }
  
  # For each Success, Advantage, Triump Triplet
  # Make that cell of the target grid true.
  t_strings_array.each do |s|
    s_count  = s.count('S')
    a_count  = s.count('A')
    tr_count = s.count('R')
    t_grid[s_count - t_success_min][a_count - t_advantage_min][tr_count - t_triumph_min] = true
  end
  # And now, some shenanigans.
  # Since a target is the lowest number of symbols needed
  # make all the values after the target in a straight line true.
  # So all SA is true if A is true, or SRR is true if SR is true.
  a_line_y = t_advantage_max - t_advantage_min + 1
  a_line_x = t_triumph_max - t_triumph_min + 1

  a_line_value = Array.new(a_line_x) { Array.new(a_line_x, false) }
  t_grid.each_index do |i|
    t_grid[i].each_index do |j|
      t_grid[i][j].each_index do |k|
        t_grid[i][j][k] = (t_grid[i][j][k - 1] || t_grid[i][j][k]) if( k > 0)
        t_grid[i][j][k] = (t_grid[i][j - 1][k] || t_grid[i][j][k]) if( j > 0)
        t_grid[i][j][k] = (t_grid[i - 1][j][k] || t_grid[i][j][k]) if( i > 0)

      end
    end
  end
  success_max, advantage_max, threat_max, failure_max, triumph_max, despair_max = dice_string_interpolation d_string
  target_probability = 0
  #note we are starting iteraton at the target's minimum successes.
  result_grid[t_success_min..success_max].each_with_index do |result_success_line, i|
    # Make sure that s_x remains in boundaries of t_grid.
    # As above, in "Shenanigans", everything after a cell will be part of the solution if the preceeding one is.
    # Since the target grid has a compacted range, everything past a maximum cell shares that cell's truth value.
    s_x = (i + t_success_min) < t_success_max ? i: t_success_max - t_success_min
    s_x = 0 if (t_success_max - t_success_min) == 0

    result_success_line[t_advantage_min..advantage_max].each_with_index do |result_advantage_line, j|
      a_y = (j + t_advantage_min) < t_advantage_max ? j : t_advantage_max - t_advantage_min
      a_y = 0 if t_advantage_max - t_advantage_min == 0
      result_advantage_line[t_triumph_min..triumph_max].each_with_index do |result_triumph_line, k|
        tr_z = (k + t_triumph_min) < t_triumph_max ? k : t_triumph_max - t_triumph_min
        tr_z = 0 if t_triumph_max - t_triumph_min == 0
        next if !(t_grid[s_x][a_y][tr_z])
        result_triumph_line[0..despair_max].each do |result_cell|
          #Success, Advantage Probability
          target_probability += result_cell
        end
      end
    end
    # Only go through the threat loop is there is a target that doesn't need advantage
    next if !(t_advantage_min == 0)
    result_success_line.reverse[0..threat_max - 1].each do |result_threat_line|
      break if (threat_max == 0)
      result_threat_line[t_triumph_min..triumph_max].each_with_index do |result_triumph_line, k|
        tr_z = (k + t_triumph_min) < t_triumph_max ? k : t_triumph_max - t_triumph_min
        tr_z = 0 if t_triumph_max - t_triumph_min == 0
        next if !(t_grid[s_x][0][tr_z])
        result_triumph_line[0..despair_max].each do |result_cell|
          #Success, Threat Probability
          target_probability += result_cell
        end
      end
    end
  end
  return target_probability
end

# +++++ SCRIPT START +++++
# Why'd you add those methods, Nik?
# Readability.
# But it might be LESS readable now.
# Look, why are you arguing with yourself in the comments of a program you're writing?
# Because. Shut Up.
while ARGV.length > 0
  if ARGV[0][0] == '-'
    case ARGV[0][1]
    when 'X'
      expanded_toggle = true
      ARGV.shift
    when 'C'
      combinations_toggle = true
      ARGV.shift
    when 'T'
      target_string = ARGV.shift[3..-1]
      target_toggle = true
    when 'D'
      dice_string = ARGV.shift[3..-1]
    when 'R'
      rounding = ARGV.shift[3..-1]
      $standard_round = rounding.to_i if rounding.to_i > 0 && rounding.to_i < 10
    when 'G'
      group_target_string = ARGV.shift[3..-1]
      group_target_toggle = true
    else
      puts 'invalid runtime argument (-X, -C, -R:/[0-9]+/ -T:[/[ASTFRD]*/] -D:/[BSADPC]*/ accepted)'
      ARGV.shift
    end
  else
    puts 'Runtime arguments must start with -'
    ARGV.shift
  end
end

if dice_string.nil? || dice_string == ''
  puts 'Dice Pool Input: (Use /[BSADPC]*/ to signify (B)oost, (S)etback, (A)bility, (D)ifficulty, (P)roficiency, (C)hallenge)'
  STDOUT.flush
  dice_string = gets.chomp.upcase
end

if !(/[BSADPC]+/ === dice_string)
  puts 'Invalid Die String'
  exit
end

if target_toggle && (target_string.nil? || target_string == '')
  puts 'Target Input: \
  (Use /[ASTFRD]*/ to signify (S)uccesses, (F)ailures, (A)dvantages, (T)hreats, t(R)iumphs and (D)espairs.)'
  STDOUT.flush
  target_string = gets.chomp.upcase
end

if target_toggle && !(/[ASTFRD]+/ === target_string)
  puts 'Invalid Target String'
  exit
end

print_combinations dice_grid if combinations_toggle

#calculate the probability of the dice string
result_grid = calculate_probability_grid dice_string

# create percentile pools for the following:
# 0 = Success
# 1 = Advantage
# 2 = Threat
# 3 = Failure
probability_array = Array.new(4, 0.0)

# Get the maximum number of symbols able to appear in this dice pool.
success_max, advantage_max, threat_max, failure_max, triumph_max, despair_max = dice_string_interpolation dice_string

puts "\n++++RESULTS for Dice Pool: #{dice_string}++++\n"
puts '------------' if ( expanded_toggle == true)
# Print out the Results (and at that same time grab the total probabilities)
# Success Loop
result_grid[0..success_max].each_with_index do |result_success_line, i|
  # Advantage Loop
  result_success_line[0..advantage_max].each_with_index do |result_advantage_line, j|
    # Triumph Loop
    result_advantage_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair Loop
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        # Only add & print this value if there is a value to see.
        # Don't want the output clogged with 0% statements.
        if (result_cell != 0)
          # if there is success, then add this percent to the sucess probability.
          probability_array[0] += (i != 0) ? result_cell : 0
          # Likewise for advantage
          probability_array[1] += (j != 0) ? result_cell : 0
          # Print the probability
          print_probability 'Success', 'Advantage', result_cell, i, j, k, l if expanded_toggle
        end
      end
    end
  end
  # Threat Loop
  result_success_line.reverse[0..threat_max - 1].each_with_index do |result_threat_line, j|
    # Fence Posting, since each would run on [0..-1] if threat_max = 0,
    # which is basically the whole array instead of none of it.
    break if threat_max == 0
    # Triumph Loop
    result_threat_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair Loop
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          probability_array[0] += (i != 0) ? result_cell : 0
          # You can't get in here unless threat is generated
          # so add it to threat probability.
          probability_array[2] += result_cell
          print_probability 'Success', 'Threat', result_cell, i, j + 1, k, l if expanded_toggle
        end
      end
    end
  end
  puts '------------' if expanded_toggle
end
   
# Failure Loop
result_grid.reverse[0..failure_max - 1].each_with_index do |result_line, i|
  # Only continue this loop is failure was generated. Fence Posting, since each would run on [0..-1]
  # which is basically the whole array instead of none of it
  break if failure_max == 0
  # Advantage Loop
  result_line[0..advantage_max].each_with_index do |result_advantage_line, j|
    # Triumph Loop
    result_advantage_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair Loop
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          # See Success and Advantage
          probability_array[1] += (j != 0) ? result_cell : 0
          # Same as threat: the only way into this loop is if a failure was generated.
          probability_array[3] += result_cell
          print_probability 'Failure', 'Advantage', result_cell, i + 1, j, k, l if expanded_toggle
        end
      end
    end
  end
  # Threat Loop
  result_line.reverse[0..threat_max - 1].each_with_index do |result_threat_line, j|
    break if threat_max == 0
    # Triumph Loop
    result_threat_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair Loop
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          probability_array[2] += result_cell
          probability_array[3] += result_cell
          print_probability 'Failure', 'Threat', result_cell, i + 1, j + 1, k, l if expanded_toggle
        end
      end
    end
  end
  puts '------------' if expanded_toggle
end

puts "Total Chance of Success: #{probability_array[0].round($standard_round)}%"
puts "Total Chance of Advantage: #{probability_array[1].round($standard_round)}%"
puts "Total Chance of Threat: #{probability_array[2].round($standard_round)}%"
puts "Total Chance of Failure Symbol: #{probability_array[3].round($standard_round)}%"
puts "Total Chance of Reaching Target (#{target_string}): #{(target_calculation result_grid, target_string, dice_string).round($standard_round)}%" if target_toggle == true
puts "Total Chance of Reaching Group Target (#{group_target_string}): #{(group_target_calculation result_grid, group_target_string, dice_string).round($standard_round)}%" if group_target_toggle == true
puts "Total Triumph Chance: #{((1.0 - (11.0 / 12.0)**(dice_string.count 'P')) * 100).round($standard_round)}%" if (dice_string.count 'P') > 0
puts "Total Despair Chance: #{((1.0 - (11.0 / 12.0)**(dice_string.count 'C')) * 100).round($standard_round)}%" if (dice_string.count 'C') > 0
puts '+++++++++++++++'
