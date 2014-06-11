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
expanded = false # expanded output toggle
combinations = false # Show all dice combinations Toggle
dice_string = nil # Input String of dice pool. Should consist of BSADPC's.
target_toggle = false # Target probability computation toggle
target_string = nil # Target input string. Should be made of S & A's.
target_success = 0 # Numerical representation of Target String's Successes
target_advantage = 0 # Numberical representation of Target String's Advantages

while ARGV.length > 0
  if (ARGV[0][0] == '-')
    if (ARGV[0][1] == 'X')
      expanded = true
      ARGV.shift
    elsif (ARGV[0][1] == 'C')
      combinations = true
      ARGV.shift
    elsif (ARGV[0][1] == 'T')
      target_string = ARGV.shift
      target_string = target_string[3..-1]
      p target_string
      target_toggle = true
    else
      puts "invalid runtime argument (-X, -C, -T:[/[ASTF]/] accepted)"
      ARGV.shift
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

# Find the amount of Success/Failure needed for target
if (target_toggle == true)
  target_success   = target_string.count('S') - target_string.count('F')
  target_advantage = target_string.count('A') - target_string.count('T')
  # organize the target string
  target_string = target_success >= 0 ? ('S' * target_success) : ('F' * target_success.abs)
  target_string += target_advantage >= 0 ? ('A' * target_advantage) : ('T' * target_advantage.abs)
end

# count the number of each type of die input
boost_num       = dice_string.count 'B'
setback_num     = dice_string.count 'S'
ability_num     = dice_string.count 'A'
difficulty_num  = dice_string.count 'D'
proficiency_num = dice_string.count 'P'
challenge_num   = dice_string.count 'C'

# Organize the dice_string
dice_string = 'P' * proficiency_num + 'A' * ability_num + \
'C' * challenge_num + 'D' * difficulty_num + \
'B' * boost_num + 'S' * setback_num

if (dice_string.length < 1)
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
triumph_max = proficiency_num
despair_max = challenge_num

puts "Max Success: #{success_max}, Max Advantage: #{advantage_max}"
puts "Max Failure: #{failure_max}, Max Threat: #{threat_max}"
puts "Max Triumph: #{triumph_max}, Max Despair: #{despair_max}"

#Combinations. Note that this is REALLY BLOODY SLOW.
if combinations == true then
    die_grid = []
    #populate die grid with the input dice
    boost_num.times       { die_grid << boost     }
    setback_num.times     { die_grid << setback   }
    ability_num.times     { die_grid << ability   }
    difficulty_num.times  { die_grid << difficulty  }
    proficiency_num.times { die_grid << proficiency }
    challenge_num.times   { die_grid << challenge   }
    
    die_grid.shift.product(*die_grid) { |combi| p combi }
end

# create a result grid off those ranges.
result_grid = Array.new(success_max + failure_max + 1) \
{ Array.new(advantage_max + threat_max + 1, 0.0) }

# Let's do some MAGIC!
# create a new "die" from the dice that came before.
# Then add the next die to that one.
# At the end of the loop, you'll have 2 probability sets:
# one for good dice, one for bad.
success_temp, advantage_temp, failure_temp, threat_temp = 1,1,1,1
bad_grid = Array.new(failure_temp) { Array.new(threat_temp, 1.0) }
good_grid = Array.new(success_temp) { Array.new(advantage_temp, 1.0) }

dice_string.each_char do |die|
  temp_die = []
  case die
  when 'B'
    temp_die = boost
    success_temp   += 1
    advantage_temp += 2
    possibilities = 6
    temp_die_grid = Array.new(2) { Array.new(3,0.0) }
  when 'S'
    temp_die = setback
    failure_temp   += 1
    threat_temp  += 1
    possibilities = 6
    temp_die_grid = Array.new(2) { Array.new(2,0.0) }
  when 'A'
    temp_die = ability
    success_temp   += 2
    advantage_temp += 2
    possibilities = 8
  when 'D'
    temp_die = difficulty
    failure_temp   += 2
    threat_temp  += 2
    possibilities = 8
  when 'P'
    temp_die = proficiency
    success_temp   += 2
    advantage_temp += 2
    possibilities = 12
  when 'C'
    temp_die = challenge
    failure_temp   += 2
    threat_temp  += 2
    possibilities = 12
  end
  temp_die_grid = Array.new(3) { Array.new(3,0.0) } if /[^BS]/ === die
  temp_die.each do |side|
    success_count = side.nil? ? 0 : side.scan(/[SF]/).length
    advantage_count = side.nil? ? 0 : side.scan(/[AT]/).length
    temp_die_grid[success_count][advantage_count] += 1
  end
  
  #make the values of the temp die into probabilities.
  temp_die_grid.each { |x| x.collect! { |n| n / possibilities } }
  
  #make a new grid based on the type of die the temp_die is, good or bad.
  result_grid_temporary = /[BAP]/ === die ? \
  Array.new(success_temp) { Array.new(advantage_temp, 0.0) } : \
  Array.new(failure_temp) { Array.new(threat_temp,    0.0) }
  
  case die
  when /[BAP]/
    good_grid.each_with_index do |grid_line, i|
      grid_line.each_with_index do |grid_cell, j|
        temp_die_grid.each_with_index do |temp_die_line, k|
          temp_die_line.each_with_index do |temp_die_cell, l|
            result_grid_temporary[i+k][j+l] += grid_cell * temp_die_cell
          end
        end
      end
    end
    good_grid = result_grid_temporary
  when /[SDC]/
    bad_grid.each_with_index do |grid_line, i|
      grid_line.each_with_index do |grid_cell, j|
        temp_die_grid.each_with_index do |temp_die_line, k|
          temp_die_line.each_with_index do |temp_die_cell, l|
            result_grid_temporary[i+k][j+l] += grid_cell * temp_die_cell
          end
        end
      end
    end
    bad_grid = result_grid_temporary
  end
end

good_grid.each_with_index do |good_line, i|
    good_line.each_with_index do |good_cell, j|
        bad_grid.each_with_index do |bad_line, k|
            bad_line.each_with_index do |bad_cell, l|
                result_grid[i-k][j-l] += bad_cell * good_cell
            end
        end
    end
end

result_grid.each { |x| x.collect! { |n| n * 100 } }

# create percentile pools for
# success rate, advantage rate, threat rate and target rate
success_probability, advantage_probability, threat_probability, failure_symbol_probability, target_probability = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

puts "\n++++RESULTS for Dice Pool: #{dice_string}++++\n"
puts '------------' if ( expanded == true)
# Print out the Results (and at that same time grab the total probabilities)
# Success
result_grid[0..success_max].each_with_index do |result_line, i|
  # Advantage
  result_line[0..advantage_max].each_with_index do |result_cell, j|
    # Only show the results if there is a chance of it happening.
    if (result_cell != 0)
      # if there is success, then add this percent to the growing success die percentage.
      success_probability += (i != 0) ? result_cell : 0
      # Likewise for advantage
      advantage_probability += (j != 0) ? result_cell : 0
      target_probability += result_cell if (target_toggle == true && target_success >=0 && target_advantage >= 0 && i >= target_success && j >= target_advantage)
      # Print the result
      puts "#{i} Success & #{j} Advantage: #{result_cell.round(2)}%" \
      if expanded == true
    end
  end
  # Threat
  result_line.reverse[0..threat_max - 1].each_with_index do |result_cell, j|
    break if (threat_max == 0)
    if (result_cell != 0)
      success_probability += (i != 0) ? result_cell : 0
      # You can't get in here unless threat is generated
      # so all these add to threat probability.
      threat_probability += result_cell
      target_probability += result_cell \
      if target_toggle == true && target_success >=0 && target_advantage <= 0 && \
        i >= target_success && j + 1 >= target_advantage.abs
      puts "#{i} Success & #{j + 1} Threat: #{result_cell.round(2)}%" \
        if expanded == true
    end
  end
  puts '------------' if (expanded == true)
end
   
# Failure
result_grid.reverse[0..failure_max - 1].each_with_index do |result_line, i|
  break if failure_max == 0
  # Advantage
  result_line[0..advantage_max].each_with_index do |result_cell, j|
  if (result_cell != 0)
    # See Success and Advantage
    advantage_probability += (j != 0) ? result_cell : 0
    failure_symbol_probability += result_cell
    target_probability += result_cell \
    if target_toggle == true && target_success <= 0 && target_advantage >= 0 && \
        i + 1 >= target_success.abs && j >= target_advantage
      puts "#{i + 1} Failure & #{j} Advantage: #{result_cell.round(2)}%" \
        if expanded == true
    end
  end
  # Threat
  result_line.reverse[0..threat_max - 1].each_with_index do |result_cell, j|
    break if threat_max == 0
    if (result_cell != 0)
      threat_probability += result_cell
      failure_symbol_probability += result_cell
      target_probability += result_cell \
        if target_toggle == true && target_success <= 0 && target_advantage <= 0 && \
          i + 1 >= target_success.abs && j + 1 >= target_advantage.abs
      puts "#{i + 1} Failure & #{j + 1} Threat: #{result_cell.round(2)}%" \
      if expanded == true
    end
  end
  puts '------------' if (expanded == true)
end
    
puts "Total Chance of Success: #{success_probability.round(2)}%"
puts "Total Chance of Advantage: #{advantage_probability.round(2)}%"
puts "Total Chance of Threat: #{threat_probability.round(2)}%"
puts "Total Chance of a seeing a Failure Symbol: #{failure_symbol_probability.round(2)}%"
puts "Total Chance of Reaching Target (#{target_string}): #{target_probability.round(2)}%" if target_toggle == true
puts "Total Triumph Chance: #{((1.0 - (11.0 / 12.0)**(proficiency_num)) * 100).round(2)}%" if proficiency_num > 0
puts "Total Despair Chance: #{((1.0 - (11.0 / 12.0)**(challenge_num)) * 100).round(2)}%" if challenge_num > 0
puts '+++++++++++++++'