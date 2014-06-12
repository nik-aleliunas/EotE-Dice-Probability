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
  
  
  good_grid.each_with_index do |good_grid_success_line, i|
    good_grid_success_line.each_with_index do |good_grid_advantage_line, j|
      good_grid_advantage_line.each_with_index do |good_grid_triumph_line, k|
        good_grid_triumph_line.each_with_index do |good_grid_despair_cell, l|
          bad_grid.each_with_index do |bad_grid_success_line, m|
            bad_grid_success_line.each_with_index do |bad_grid_advantage_line, n|
              bad_grid_advantage_line.each_with_index do |bad_grid_triumph_line, o|
                bad_grid_triumph_line.each_with_index do |bad_grid_despair_cell, p|
                  # i is successes, m is failures. That means the absolute value of a negative index is the failure index. Same with threat.
                  result_grid[i - m][j - n][k + o][l + p] += good_grid_despair_cell * bad_grid_despair_cell
                end
              end
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
  
  grid1.each_with_index do |grid1_success_line, i|
    grid1_success_line.each_with_index do |grid1_advantage_line, j|
      grid1_advantage_line.each_with_index do |grid1_triumph_line, k|
        grid1_triumph_line.each_with_index do |grid1_despair_cell, l|
          grid2.each_with_index do |grid2_success_line, m|
            grid2_success_line.each_with_index do |grid2_sadvantage_line, n|
              grid2_sadvantage_line.each_with_index do |grid2_striumph_line, o|
                grid2_striumph_line.each_with_index do |grid2_despair_cell, p|
                  result_grid[i + m][j + n][k + o][l + p] += grid1_despair_cell * grid2_despair_cell
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
# Success
result_grid[0..success_max].each_with_index do |result_success_line, i|
  # Advantage
  result_success_line[0..advantage_max].each_with_index do |result_advantage_line, j|
    # Triumph
    result_advantage_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        # Only print the results if there is a chance of it happening. a bit of speed up.
        if (result_cell != 0)
          # if there is success, then add this percent to the growing success die percentage.
          probability_array[0] += (i != 0) ? result_cell : 0
          # Likewise for advantage
          probability_array[1] += (j != 0) ? result_cell : 0
          # Print the result
          print_probability 'Success', 'Advantage', result_cell, i, j, k, l if expanded_toggle
        end
      end
    end
  end
  # Threat
  result_success_line.reverse[0..threat_max - 1].each_with_index do |result_threat_line, j|
    break if threat_max == 0
    # Triumph
    result_threat_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          probability_array[0] += (i != 0) ? result_cell : 0
          # You can't get in here unless threat is generated
          # so all these add to threat probability.
          probability_array[2] += result_cell
          print_probability 'Success', 'Threat', result_cell, i, j + 1, k, l if expanded_toggle
        end
      end
    end
  end
  puts '------------' if expanded_toggle
end
   
# Failure
result_grid.reverse[0..failure_max - 1].each_with_index do |result_line, i|
  break if failure_max == 0
  # Advantage
  result_line[0..advantage_max].each_with_index do |result_advantage_line, j|
    # Triumph
    result_advantage_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          # See Success and Advantage
          probability_array[1] += (j != 0) ? result_cell : 0
          probability_array[3] += result_cell
          print_probability 'Failure', 'Advantage', result_cell, i + 1, j, k, l if expanded_toggle
        end
      end
    end
  end
  # Threat
  result_line.reverse[0..threat_max - 1].each_with_index do |result_threat_line, j|
    break if threat_max == 0
    # Triumph
    result_threat_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair
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
puts "Total Triumph Chance: #{((1.0 - (11.0 / 12.0)**(dice_string.count 'P')) * 100).round($standard_round)}%" if (dice_string.count 'P') > 0
puts "Total Despair Chance: #{((1.0 - (11.0 / 12.0)**(dice_string.count 'C')) * 100).round($standard_round)}%" if (dice_string.count 'C') > 0
puts '+++++++++++++++'
