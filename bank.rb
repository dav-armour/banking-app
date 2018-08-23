# Davo's banking app with basic functionality

# assign global variables
$balance = 0.0
$message = ""

def main
  system('clear')
  displayMenu
  if $message != ""
    puts $message
    puts "-----------------------------"
  end
  $message = ""
  print "Choose Option (1-4): "
  input = gets.chomp
  case input
  when "1"
    $message = "Balance: $%.2f" % $balance
    main
  when "2"
    print "How much to deposit: $"
    amount = getAmount
    updateBalance(amount)
    $message = "Succesfully Deposited $%.2f" % amount
    $message += "\nNew Balance: $%.2f" % $balance
    main
  when "3"
    print "How much to withdraw: $"
    amount = getAmount
    updateBalance(-amount)
    $message = "Succesfully Withdrew $%.2f" % amount
    $message += "\nNew Balance: $%.2f" % $balance
    main
  when "4"
    return
  else
    $message = "ERROR: Wrong input entered"
    main
  end
end

# prints menu to screen using ASCII art :P
def displayMenu
  puts "-----------------------------"
  puts "|     Davo's Banking App    |"
  puts "-----------------------------"
  puts "|                           |"
  puts "| 1) View Balance           |"
  puts "| 2) Deposit Money          |"
  puts "| 3) Withdraw Money         |"
  puts "| 4) Exit                   |"
  puts "|                           |"
  puts "-----------------------------"
end

def getAmount
  amount = gets.chomp.to_f
  if amount < 0
    system('clear')
    $message = "ERROR: Must be positive number"
  end
  amount
end

def updateBalance(amount)
  # check if withdrawing and there is enough funds
  if amount < 0 and ($balance - amount) < 0
    system('clear')
    $message = "ERROR: Not enough funds"
  end
  $balance += amount.round(2)
end

# run program
main
