# Edge of the Empire Dice Probability Calculator.
# Calculate the Probability of a given dice set
# - Nik Aleliunas

# Dice symbol key:
# (S)uccess, (A)dvantage, (F)ailure), (T)hreat, t(R)iumph, (D)espair
boost = [nil, nil, 'S', 'SA', 'AA', 'A']
setback = [nil, nil, 'F', 'F', 'T', 'T']
ability = [nil, 'S', 'S', 'SS', 'A', 'A', 'SA', 'AA']
difficulty = [nil, 'F', 'FF', 'T', 'T', 'T', 'TT', 'FT']
proficiency = [nil, 'S', 'S', 'SS', 'SS', 'A', 'SA', 'SA', 'SA', 'AA', 'AA', 'SR']
challenge = [nil, 'F', 'F', 'FF', 'FF', 'T', 'T', 'FT', 'FT', 'TT', 'TT', 'FD']
simplified = false # Simplified output toggle
combinations = false # Show all dice combinations Toggle
dice_string = nil # Input String of dice pool. Should consist of BSADPC's.
target_toggle = false # Target probability computation toggle
target_string = nil # Target input string. Should be made of S & A's.
target_success = 0 # Numerical representation of Target String's Successes
target_advantage = 0 # Numberical representation of Target String's Advantages

while ARGV.length > 0
  if (ARGV[0][0] == '-')
    if (ARGV[0][1] == 'S')
      simplified = true
      ARGV.shift
    elsif (ARGV[0][1] == 'C')
      combinations = true
      ARGV.shift
    elsif (ARGV[0][1] == 'T')
      target_string = ARGV.shift
      target_string = target_string[3..-1]
      p target_string
      target_toggle = true
    end
  else
    dice_string = ARGV.shift.upcase
  end
end

if dice_string.nil?
  puts 'Dice Pool: (Use the first letter to signify a die: B,S,A,D,P or C.)'
  STDOUT.flush
  dice_string = gets.chomp.upcase
end

if target_toggle == true && (target_string.nil? || target_string == '')
  puts 'Target Success/Advantage: \
  (Use S or A to signify one Success or Advantage.)'
  STDOUT.flush
  target_string = gets.chomp.upcase
end

if (target_toggle == true)
  target_success   = target_string.count 'S'
  target_advantage = target_string.count 'A'
end

# count the number of each type of die input
boost_num       = dice_string.count 'B'
setback_num     = dice_string.count 'S'
ability_num     = dice_string.count 'A'
difficulty_num  = dice_string.count 'D'
proficiency_num = dice_string.count 'P'
challenge_num   = dice_string.count 'C'

# Create the number of possibilities. (sides on die)^(# of dice)
possibilities_max = 6**(boost_num + setback_num) * 8**(ability_num + difficulty_num) * 12**(proficiency_num + challenge_num)

if (possibilities_max <= 1)
  p 'No Dice.'
  exit
end

# calculate the maximum range of success/failure & advantage/threat.
# Most die have a side with 2 of each symbol, except advantage and setback die.
# Failures/Threats will be counted at negative indecies.
# t(R)iumph and (D)espair are only counted for their successes.
success_max = boost_num + 2 * (ability_num + proficiency_num)
advantage_max =  2 * (boost_num + ability_num + proficiency_num)

failure_max = setback_num + 2 * (difficulty_num + challenge_num)
threat_max = setback_num + 2 * (difficulty_num + challenge_num)

puts "Max Success: #{success_max}, Max Advantage: #{advantage_max}"

puts "Max Failure: #{failure_max}, Max Threat: #{threat_max}"
# create a result grid off those ranges.
result_grid = Array.new(success_max + failure_max + 1) \
 { Array.new(advantage_max + threat_max + 1, 0.0) }

# create die grid
die_grid = []

# populate die grid with the input dice
boost_num.times       { die_grid << boost       }
setback_num.times     { die_grid << setback     }
ability_num.times     { die_grid << ability     }
difficulty_num.times  { die_grid << difficulty  }
proficiency_num.times { die_grid << proficiency }
challenge_num.times   { die_grid << challenge   }

# iterate through all possible combinations of dice in grid
# and add them to the result grid
die_grid.shift.product(*die_grid) do |combi|
  combi = combi.join
  p combi if (combinations == true)
  success_count = (combi.count 'S') - (combi.count 'F')
  advantage_count = (combi.count 'A') - (combi.count 'T')
  result_grid[success_count][advantage_count] += 1
end

# create percentile pools for
# success rate, advantage rate, threat rate and target rate
success_probability, advantage_probability, threat_probability, \
target_probability = 0.0, 0.0, 0.0, 0.0
puts "\n++++RESULTS for Dice Pool: #{dice_string}++++\n"
puts '------------' if ( simplified == false)
# Success
result_grid[0..success_max].each_with_index do |result_line, i|
  # Advantage
  result_line[0..advantage_max].each_with_index do |result_cell, j|
    # Only show the results if there is a chance of it happening.
    if (result_cell != 0)
      # Make the result into a percentage
      result_cell /= (possibilities_max * 0.01)
      # if there is success, then add this percent to the growing success die percentage.
      success_probability += (i != 0) ? result_cell : 0
      # Likewise for advantage
      advantage_probability += (j != 0) ? result_cell : 0
      target_probability += result_cell \
      if target_toggle == true && i >= target_success && j >= target_advantage
      # Print the result
      puts "#{i} Success & #{j} Advantage: #{result_cell.round(2)}%" \
      if simplified == false
    end
  end
  result_line.reverse[0..threat_max - 1].each_with_index do |result_cell, j|
    break if (threat_max == 0)
    if (result_cell != 0)
      result_cell /= (possibilities_max * 0.01)
      success_probability += (i != 0) ? result_cell : 0
      # You can't get in here unless threat is generated
      # so all these add to threat probability.
      threat_probability += result_cell
      puts "#{i} Success & #{j + 1} Threat: #{result_cell.round(2)}%" \
      if simplified == false
    end
  end
  puts '------------' if (simplified == false)
end

# Failure
result_grid.reverse[0..failure_max - 1].each_with_index do |result_line, i|
  break if (failure_max == 0)
  # Advantage
  result_line[0..advantage_max].each_with_index do |result_cell, j|
    if (result_cell != 0)
      result_cell /= (possibilities_max * 0.01)
      # See Success and Advantage
      advantage_probability += (j != 0) ? result_cell : 0
      puts "#{i + 1} Failure & #{j} Advantage: #{result_cell.round(2)}%" \
      if simplified == false
    end
  end
  # Threat
  result_line.reverse[0..threat_max - 1].each_with_index do |result_cell, j|
    break if (threat_max == 0)
    if (result_cell != 0)
      result_cell /= (possibilities_max * 0.01)
      threat_probability += result_cell
      puts "#{i + 1} Failure & #{j + 1} Threat: #{result_cell.round(2)}%" \
      if simplified == false
    end
  end
  puts '------------' if (simplified == false)
end

puts "Total Chance of Success: #{success_probability}"
puts "Total Chance of Advantage: #{advantage_probability}"
puts "Total Chance of Threat: #{threat_probability}"
puts "Total Chance of Reaching Target (#{target_string}): #{target_probability}" if target_toggle == true
puts '+++++++++++++++'
