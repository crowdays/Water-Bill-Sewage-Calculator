#-------------------------------------------------------------------------------
# Assignment:    lj_customerdata.rb
#
# Program Name:  lj_customerdata.rb
#
#
# Purpose:       The purpose of this program is
#                to calculate customers water charge, sewage charge, using the lj_customerdata.txt file.
#
# Author:        Lorenzo Juarez
# Course:        CIS109.950
#
# Created:       2/28/23
#
#------------------------------------------------------------------------------
#colors for terminal text, for visualizing errors much easier.
T = "\e[36m"
BLUE = "\e[34m"
Purple = "\e[35m"
STOP_COLOR = "\e[0m"
#current time
require 'date'
# counters
total_customers = 0
valid_customers = 0
invalid_customers = 0
total_billed = 0
page_count = 1
processed_customers = 0
customers_on_page = 0
pages_printed = 0

#math for calculating missing data/ rejected.
def calculate_bill(last_reading, current_reading)
  if last_reading.nil? || current_reading.nil?
    return "-- MISSING DATA --", nil
  end

  usage = current_reading - last_reading
  if usage <= 0 || usage > 200
    return "--REJECTED--", usage
  end
  #water charge math,
  water_charge = 16.0 + (([usage, 3000].min - 0) * 0.0) +
    (([usage - 3000, 0].max - 0) * 3.55)
  sewage_charge = ((usage / 1000.0) * 0.35)
  total_charge = water_charge + sewage_charge

  # The output format.
  usage_output = "#{usage}"
  output = "#{' ' * 12}-----#{' ' * 46}"
  output += "\n#{' ' * 6}WATER USAGE#{' ' * 5} #{usage_output}#{' ' * 46}"
  output += "\n#{' ' * 41} WATER CHARGE\s\s$\s\s\s\s#{'%.2f' % water_charge}\s\s\s\s\s\s\s"
  output += "\n#{' ' * 40} SEWAGE CHARGE\s\s$\s\s\s\s#{'%.2f' % sewage_charge}\s\s\s\s\s\s\s\n"
  output += "#{' ' * 56}-----------\s\s\s\s\s\n#{' ' * 43}\s\sTOTAL DUE\s\s$\s\s\s\s#{'%.2f' % total_charge}\s\s\s\s"
  return output, usage
end

# Open the input and output files.
input_file = File.open("lj_CustomerData.txt", "r")
output_file = File.open("lj_CustomerBilling.txt", "w")

# Process each customer record in my input file.
input_file.each_line do |line|
  # Extract the values from the input line.
  values = line.split(/\s+/).map(&:to_i)
  meter_num, customer_num, last_reading, current_reading = values

  # This puts string is used as a debugger. I chose to leave it in because it can be helpful for who -
  # - ever uses it.
  puts "#{Purple}Processing record for customer#{BLUE} #{customer_num}#{BLUE}"

  # Check for end of file to break
  if customer_num == 99999
    break
  end

  # This is how i did the math for counting pages, because I created invalid and valid bills. it needed to be this way so-
  #- the program can count both sides and input the correct amount of pages.
  total_customers += 1
  processed_customers += 1
  customers_on_page += 1

  if processed_customers % 4 == 1
    page_number = pages_printed + 1
    pages_printed += 1
    output_file.puts("|PAGE: #{page_number}#{' ' * 64}|")

  end

  # Calculate the bill.
  bill, usage = calculate_bill(last_reading, current_reading)

  if bill == "--REJECTED--"
    # Count rejected bills separately so everything lines up.
    invalid_customers += 1
    #title.
    output_file.puts("|-----------------------------------------------------------------------|")
    output_file.puts("#{' ' * 28}Daly Water Company#{' ' * 26}")
    output_file.puts("#{' ' * 28}#{Time.now.strftime("%B %d, %Y")}#{' ' * 27}")
    output_file.puts("#{' ' * 72}")
    output_file.puts("#{' ' * 72}")

    # Output the bill.
    output_file.puts("#{' ' * 6}CUSTOMER#{' ' * 7}#{customer_num}#{' ' * 18}METER NUMBER\s\s\s\s\s\s#{meter_num}#{' ' * 13}")
    output_file.puts("#{' ' * 6}NEW READING\s\s\s #{current_reading}#{' ' * 49}")
    output_file.puts("#{' ' * 6}OLD READING\s\s\s #{last_reading}#{' ' * 49}")
    output_file.puts("#{' '* 22}-----")
    output_file.puts("#{' '* 6}WATER USAGE\s\s\s\s\s\s #{usage}")
    output_file.puts("#{' '* 44}WATER CHARGE\s\s#{bill}")
    output_file.puts("#{' '* 43}SEWAGE CHARGE\s\s#{bill}")
    output_file.puts("|-----------------------------------------------------------------------|")
  else

    # Count processed bills separately so everything lines up.
    valid_customers +=1
    total_billed += bill.scan(/\d+\.\d+/).join.to_f
    output_file.puts("|-----------------------------------------------------------------------|")
    output_file.puts("#{' ' * 28}Daly Water Company#{' ' * 26}")
    output_file.puts("#{' ' * 28}#{Time.now.strftime("%B %d, %Y")}#{' ' * 27}")
    output_file.puts("#{' ' * 72}")
    output_file.puts("#{' ' * 72}")

    # Output the bill.
    output_file.puts("#{' ' * 6}CUSTOMER#{' ' * 7}#{customer_num}#{' ' * 16}METER NUMBER\s\s\s\s\s\s #{meter_num}")
    output_file.puts("#{' ' * 6}NEW READING\s\s\s #{current_reading}#{' ' * 49}")
    output_file.puts("#{' ' * 6}OLD READING\s\s\s #{last_reading}#{' ' * 49}")
    output_file.puts "\n\s\s\s\s\s\s\s\s\s#{bill}"
    output_file.puts("|-----------------------------------------------------------------------|")
    page_count += 1
    end
  end

#This code is added to make sure a new page is printed once output gets to summary.
if customers_on_page > 0
  page_number = pages_printed + 1
  output_file.puts("|PAGE: #{page_number}#{' ' * 64}|")
  output_file.puts("|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|")
  output_file.puts("|#{'-' * 30}End of Report#{'-' * 28}|")

end

# Output the summary.
output_file.puts("|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|")
output_file.puts("|#{' ' * 28}Daly Water Company#{' ' * 25}|")
output_file.puts("|#{' ' * 28}#{Time.now.strftime("%B %d, %Y")}#{' ' * 26}|")
output_file.puts("|#{' ' * 71}|")
output_file.puts("|#{' ' * 28}SUMMARY STATEMENT#{' ' * 26}|")
output_file.puts("|#{' ' * 71}|")
output_file.puts("|Valid Bills Processed\s\s\s\s\s\s\s\s\s #{valid_customers}#{' ' * 38}|")
output_file.puts("|Rejected Bills Processed\s\s\s\s\s  #{invalid_customers}#{' ' * 39}|")
output_file.puts("|#{' ' * 30}---#{' ' * 38}|")
output_file.puts("|TOTAL BILLS PROCESSED \s\s\s\s\s\s\s\s\s#{total_customers}\s\s\sTOTAL USAGE CHARGES $\s\s#{'%.2f' % total_billed}\s\s\s\s\s\s|")
output_file.puts("|#{'-' * 71}|")

# Close the files.
input_file.close
output_file.close
# This code tells the user everything is in the .txt file. If this doesnt print theres an error.
puts"#{T}file output completed, please check .txt file.#{STOP_COLOR}"





