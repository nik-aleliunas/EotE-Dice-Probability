# Edge of the Empire Dice Probability Calculator.
# Calculate the Probability of a given dice set
# - Nik Aleliunas

# Dice key:
# (B)oost, (S)etback, (A)bility, (D)ifficulty, (P)roficiency, (C)hallenge

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
target_toggle = false # Target probability computation toggle

while ARGV.length > 0
  if ARGV[0][0] == '-'
    if ARGV[0][1] == 'X'
      expanded = true
      ARGV.shift
    elsif ARGV[0][1] == 'C'
      combinations = true
      ARGV.shift
    elsif ARGV[0][1] == 'T'
      target_string = ARGV.shift[3..-1]
      target_toggle = true
    elsif ARGV[0][1] == 'D'
      dice_string = ARGV.shift[3..-1]
    else
      puts 'invalid runtime argument (-X, -C, -T:[/[ASTFRD]*/] -D:/[BSADPC]*/ accepted)'
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

if target_toggle == true && (target_string.nil? || target_string == '')
  puts 'Target Input: \
  (Use /[ASTFRD]*/ to signify (S)uccesses, (F)ailures, (A)dvantages, (T)hreats, t(R)iumphs and (D)espairs.)'
  STDOUT.flush
  target_string = gets.chomp.upcase
end

# Find the amount of Success/Failure needed for target
if target_toggle == true
  target_success   = target_string.count('S') - target_string.count('F')
  target_advantage = target_string.count('A') - target_string.count('T')
  target_triumph = target_string.count('R')
  target_despair = target_string.count('D')
  # organize the target string
  target_string = target_success >= 0 ? ('S' * target_success) : ('F' * target_success.abs)
  target_string += target_advantage >= 0 ? ('A' * target_advantage) : ('T' * target_advantage.abs)
  target_string += 'R' * target_triumph
  target_string += 'D' * target_despair
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

if dice_string.length < 1
  p 'No Dice.'
  exit
end

# calculate the maximum range of success/failure & advantage/threat.
# Most die have a side with 2 of each symbol, except advantage and setback die.
# Failures/Threats will be counted at negative indecies.
success_max = boost_num + 2 * (ability_num + proficiency_num)
advantage_max =  2 * (boost_num + ability_num + proficiency_num)
failure_max = setback_num + 2 * (difficulty_num + challenge_num)
threat_max = setback_num + 2 * (difficulty_num + challenge_num)
triumph_max = proficiency_num
despair_max = challenge_num

puts "Max Success: #{success_max}, Max Advantage: #{advantage_max}"
puts "Max Failure: #{failure_max}, Max Threat: #{threat_max}"
puts "Max Triumph: #{triumph_max}, Max Despair: #{despair_max}"

# Combinations. Note that this is REALLY BLOODY SLOW.
if combinations == true
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

# create a result grid off those ranges.
result_grid = Array.new(success_max + failure_max + 1) \
 { Array.new(advantage_max + threat_max + 1) { Array.new(triumph_max + 1) { Array.new(despair_max + 1, 0.0) } } }

# Let's do some MAGIC!
# create a new "die" from the dice that came before.
# Then add the next die to that one.
# At the end of the loop, you'll have 2 probability sets:
# one for good dice, one for bad.
success_temp, advantage_temp, failure_temp, threat_temp, despair_temp, triumph_temp = 1, 1, 1, 1, 1, 1
bad_grid = Array.new(failure_temp) { Array.new(threat_temp) { Array.new(triumph_temp) { Array.new(despair_temp, 1.0) } } }
good_grid = Array.new(success_temp) { Array.new(advantage_temp) { Array.new(triumph_temp) { Array.new(despair_temp, 1.0) } } }

dice_string.each_char do |die|
  temp_die = []
  case die
  when 'B'
    temp_die = boost
    success_temp   += 1
    advantage_temp += 2
    possibilities = 6
    temp_die_grid = Array.new(2) { Array.new(3) { Array.new(1) { Array.new(1, 0.0) } } }
  when 'S'
    temp_die = setback
    failure_temp += 1
    threat_temp  += 1
    possibilities = 6
    temp_die_grid = Array.new(2) { Array.new(2) { Array.new(1) { Array.new(1, 0.0) } } }
  when 'A'
    temp_die = ability
    success_temp   += 2
    advantage_temp += 2
    possibilities = 8
  when 'D'
    temp_die = difficulty
    failure_temp += 2
    threat_temp  += 2
    possibilities = 8
  when 'P'
    temp_die = proficiency
    success_temp   += 2
    advantage_temp += 2
    triumph_temp += 1
    possibilities = 12
    temp_die_grid = Array.new(3) { Array.new(3) { Array.new(2) { Array.new(1, 0.0) } } }
  when 'C'
    temp_die = challenge
    failure_temp += 2
    threat_temp  += 2
    despair_temp += 1
    possibilities = 12
    temp_die_grid = Array.new(3) { Array.new(3) { Array.new(1) { Array.new(2, 0.0) } } }
  end
  temp_die_grid = Array.new(3) { Array.new(3) { Array.new(1) { Array.new(1, 0.0) } } } if /[^BSPC]/ === die
  temp_die.each do |side|
    success_count = side.nil? ? 0 : side.scan(/[SF]/).length
    advantage_count = side.nil? ? 0 : side.scan(/[AT]/).length
    triumph_count = side.nil? ? 0 : side.scan('R').length
    despair_count = side.nil? ? 0 : side.scan('D').length
    temp_die_grid[success_count][advantage_count][triumph_count][despair_count] += 1
  end
  
  # make the values of the temp die into probabilities.
  temp_die_grid.each { |x| x.each { |y| y.each { |z| z.map! { |n| n / possibilities } } } }
  
  # make a new grid based on the type of die the temp_die is, good or bad.
  if /[BAP]/ === die
    result_grid_temporary = Array.new(success_temp) { Array.new(advantage_temp) { Array.new(triumph_temp) { Array.new(1, 0.0) } } }
  else
    result_grid_temporary = Array.new(failure_temp) { Array.new(threat_temp)    { Array.new(1) { Array.new(despair_temp, 0.0) } } }
  end
  
  case die
  when /[BAP]/
    good_grid.each_with_index do |grid_success_line, i|
      grid_success_line.each_with_index do |grid_advantage_line, j|
        grid_advantage_line.each_with_index do |grid_triumph_line, k|
          grid_triumph_line.each_with_index do |grid_despair_cell, l|
            temp_die_grid.each_with_index do |temp_die_success_line, m|
              temp_die_success_line.each_with_index do |temp_die_advantage_line, n|
                temp_die_advantage_line.each_with_index do |temp_die_triumph_line, o|
                  temp_die_triumph_line.each_with_index do |temp_die_despair_cell, p|
                    result_grid_temporary[i + m][j + n][k + o][l + p] += grid_despair_cell * temp_die_despair_cell
                  end
                end
              end
            end
          end
        end
      end
    end
    good_grid = result_grid_temporary
  when /[SDC]/
    bad_grid.each_with_index do |grid_success_line, i|
      grid_success_line.each_with_index do |grid_advantage_line, j|
        grid_advantage_line.each_with_index do |grid_triumph_line, k|
          grid_triumph_line.each_with_index do |grid_despair_cell, l|
            temp_die_grid.each_with_index do |temp_die_success_line, m|
              temp_die_success_line.each_with_index do |temp_die_advantage_line, n|
                temp_die_advantage_line.each_with_index do |temp_die_triumph_line, o|
                  temp_die_triumph_line.each_with_index do |temp_die_despair_cell, p|
                    result_grid_temporary[i + m][j + n][k + o][l + p] += grid_despair_cell * temp_die_despair_cell
                  end
                end
              end
            end
          end
        end
      end
    end
    bad_grid = result_grid_temporary
  end
end

good_grid.each_with_index do |good_grid_success_line, i|
  good_grid_success_line.each_with_index do |good_grid_advantage_line, j|
    good_grid_advantage_line.each_with_index do |good_grid_triumph_line, k|
      good_grid_triumph_line.each_with_index do |good_grid_despair_cell, l|
        bad_grid.each_with_index do |bad_grid_success_line, m|
          bad_grid_success_line.each_with_index do |bad_grid_advantage_line, n|
            bad_grid_advantage_line.each_with_index do |bad_grid_triumph_line, o|
              bad_grid_triumph_line.each_with_index do |bad_grid_despair_cell, p|
                result_grid[i - m][j - n][k + o][l + p] += good_grid_despair_cell * bad_grid_despair_cell
              end
            end
          end
        end
      end
    end
  end
end

result_grid.each { |x| x.each { |y| y.each { |z| z.map! { |n| n * 100 } } } }

# create percentile pools for
# success rate, advantage rate, threat rate and target rate
success_probability, advantage_probability, threat_probability, failure_symbol_probability, target_probability = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

puts "\n++++RESULTS for Dice Pool: #{dice_string}++++\n"
puts '------------' if ( expanded == true)
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
          success_probability += (i != 0) ? result_cell : 0
          # Likewise for advantage
          advantage_probability += (j != 0) ? result_cell : 0
          # and now: The shittiest if statement you've ever seen!
          # it is saying: If target functionality is correct, and you're in the correct quadrant,
          # AND you're over the required target, add this probability to target.
          # if anyone can fix this that'd be great.
          target_probability += result_cell if target_toggle == true && target_success >= 0 && target_advantage >= 0 && i >= target_success && \
                                               j >= target_advantage && k >= target_triumph && l >= target_despair
                                               
          # Print the result
          
          if expanded == true
            puts case k
                 when 0
                   case l
                   when 0
                     "#{i} Success & #{j} Advantage: #{result_cell.round(2)}%"
                   else
                     "#{i} Success,  #{j} Advantage & #{l} Despair: #{result_cell.round(2)}%"
                   end
                 else
                   case l
                   when 0
                     "#{i} Success,  #{j} Advantage & #{k} Triumph: #{result_cell.round(2)}%"
                   else
                     "#{i} Success,  #{j} Advantage,  #{k} Triumph & #{l} Despair: #{result_cell.round(2)}%"
                   end
                 end
          end
        end
      end
    end
  end
  # Threat
  next if (threat_max == 0)
  result_success_line.reverse[0..threat_max - 1].each_with_index do |result_threat_line, j|
    # Triumph
    result_threat_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          success_probability += (i != 0) ? result_cell : 0
          # You can't get in here unless threat is generated
          # so all these add to threat probability.
          threat_probability += result_cell
          target_probability += result_cell \
          if target_toggle == true && target_success >= 0 && target_advantage <= 0 && \
              i >= target_success && j + 1 >= target_advantage.abs && k >= target_triumph && l >= target_despair
          if expanded == true
            puts case k
                 when 0
                   case l
                   when 0
                     "#{i} Success & #{j + 1} Threat: #{result_cell.round(2)}%"
                   else
                     "#{i} Success,  #{j + 1} Threat & #{l} Despair: #{result_cell.round(2)}%"
                   end
                 else
                   case l
                   when 0
                     "#{i} Success,  #{j + 1} Threat & #{k} Triumph: #{result_cell.round(2)}%"
                   else
                     "#{i} Success,  #{j + 1} Threat,  #{k} Triumph & #{l} Despair: #{result_cell.round(2)}%"
                   end
                 end
          end
        end
      end
    end
  end
  puts '------------' if (expanded == true)
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
          advantage_probability += (j != 0) ? result_cell : 0
          failure_symbol_probability += result_cell
          target_probability += result_cell \
          if target_toggle == true && target_success <= 0 && target_advantage >= 0 && \
            i + 1 >= target_success.abs && j >= target_advantage && k >= target_triumph && l >= target_despair
          if expanded == true
            puts  case k
                  when 0
                    case l
                    when 0
                      "#{i + 1} Failure & #{j} Advantage: #{result_cell.round(2)}%"
                    else
                      "#{i + 1} Failure,  #{j} Advantage & #{l} Despair: #{result_cell.round(2)}%"
                    end
                  else
                    case l
                    when 0
                      "#{i + 1} Failure,  #{j} Advantage & #{k} Triumph: #{result_cell.round(2)}%"
                    else
                      "#{i + 1} Failure,  #{j} Advantage,  #{k} Triumph & #{l} Despair: #{result_cell.round(2)}%"
                    end
                  end
          end
        end
      end
    end
  end
  # Threat
  next if threat_max == 0
  result_line.reverse[0..threat_max - 1].each_with_index do |result_threat_line, j|
    # Triumph
    result_threat_line[0..triumph_max].each_with_index do |result_triumph_line, k|
      # Despair
      result_triumph_line[0..despair_max].each_with_index do |result_cell, l|
        if (result_cell != 0)
          threat_probability += result_cell
          failure_symbol_probability += result_cell
          target_probability += result_cell \
          if target_toggle == true && target_success <= 0 && target_advantage <= 0 && \
            i + 1 >= target_success.abs && j + 1 >= target_advantage.abs && k >= target_triumph && l >= target_despair
          if expanded == true
            puts  case k
                  when 0
                    case l
                    when 0
                      "#{i + 1} Failure & #{j + 1} Threat: #{result_cell.round(2)}%"
                    else
                      "#{i + 1} Failure,  #{j + 1} Threat & #{l} Despair: #{result_cell.round(2)}%"
                    end
                  else
                    case l
                    when 0
                      "#{i + 1} Failure, #{j + 1} Threat & #{k} Triumph: #{result_cell.round(2)}%"
                    else
                      "#{i + 1} Failure, #{j + 1} Threat,  #{k} Triumph & #{l} Despair: #{result_cell.round(2)}%"
                    end
                  end
          end
        end
      end
    end
  end
  puts '------------' if (expanded == true)
end
    
puts "Total Chance of Success: #{success_probability.round(2)}%"
puts "Total Chance of Advantage: #{advantage_probability.round(2)}%"
puts "Total Chance of Threat: #{threat_probability.round(2)}%"
puts "Total Chance of Failure Symbol: #{failure_symbol_probability.round(2)}%"
puts "Total Chance of Reaching Target (#{target_string}): #{target_probability.round(2)}%" if target_toggle == true
puts "Total Triumph Chance: #{((1.0 - (11.0 / 12.0)**(proficiency_num)) * 100).round(2)}%" if proficiency_num > 0
puts "Total Despair Chance: #{((1.0 - (11.0 / 12.0)**(challenge_num)) * 100).round(2)}%" if challenge_num > 0
puts '+++++++++++++++'
