# Davo's banking app with basic functionality

# Import Hash Helper file
require_relative 'readWriteHashes.rb'

# assign global variables
$balance = 0.0
$message = ""

def loginMenu
  system('clear')
  displayLogin
  print "Username: "
  user = gets.chomp
  # FIXME: Check if user exists
  if File.file?("./user-data/#{user}.txt")
    puts "User Exists"
    userHashes = read_from_file("./user-data/#{user}.txt")
    userInfoHash = userHashes.first
    puts userHashes.first
    print "Password: "
    # FIXME: Hide password
    pass = gets.chomp
    if pass == userInfoHash['pass']
      puts "Password correct"
    else
      puts "Password incorrect"
    end
    $balance = userInfoHash['balance']
    $message = "Welcome #{userInfoHash['realName']}"
    mainMenu(userInfoHash)
  else
    createNewUser
  end
end

def mainMenu(userInfoHash)
  system('clear')
  displayMenu
  displayMsg
  print "Choose Option (1-4): "
  input = gets.chomp
  case input
  # View Balance
  when "1"
    $message = "Balance: $%.2f" % $balance
    mainMenu(userInfoHash)
  # Deposit Money
  when "2"
    print "How much to deposit: $"
    amount = getAmount
    updateBalance(amount, userInfoHash)
    $message = "Succesfully Deposited $%.2f" % amount
    $message += "\nNew Balance: $%.2f" % $balance
    mainMenu(userInfoHash)
  # Withdraw Money
  when "3"
    print "How much to withdraw: $"
    amount = getAmount
    success = updateBalance(-amount, userInfoHash)
    $message = "Succesfully Withdrew $%.2f" % amount
    $message += "\nNew Balance: $%.2f" % $balance
    mainMenu(userInfoHash)
  # Exit
  when "4"
    exit
  else
    $message = "ERROR: Invalid selection!"
    mainMenu(userInfoHash)
  end
end

# Prints main menu to screen using ASCII art :P
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
  displayMsg
end

# More super stylish design skills
def displayLogin
  puts "-----------------------------"
  puts "|     Davo's Banking App    |"
  puts "-----------------------------"
  puts "|                           |"
  puts "|                           |"
  puts "|   Please login            |"
  puts "|      to cointinue...      |"
  puts "|                           |"
  puts "|                           |"
  puts "-----------------------------"
  displayMsg
end

def displayMsg
  if $message != ""
    puts $message
    puts "-----------------------------"
  end
  $message = ""
end


# get input amount from user and check for errors
def getAmount
  amount = gets.chomp.to_f
  if amount < 0
    system('clear')
    $message = "ERROR: Must be positive number"
  end
  amount
end

def updateUserInfoFile(userInfoHash)
  # See for more on Open method options:  https://ruby-doc.org/core-2.5.1/IO.html#method-c-new
  path = './user-data/' + userInfoHash['username'] + '.txt'
  File.open(path, 'w') do |f|
    f.puts hash_to_json(userInfoHash)
    f.close
  end
end

def updateBalance(amount, userInfoHash)
  # check if withdrawing and there is enough funds
  if ($balance + amount) < 0
    system('clear')
    $message = "ERROR: Not enough funds"
    mainMenu(userInfoHash)
  else
    $balance += amount.round(2)
    userInfoHash['balance'] = $balance
    updateUserInfoFile(userInfoHash)
  end
end

def createNewUser
  system('clear')
  $message = "ERROR: User not found"
  displayLogin
  print "Create new user? (Y/N): "
  answer = gets.chomp
  if answer == 'Y' or answer == 'y'
    print "Username: "
    user = gets.chomp
    print "Real Name: "
    realName = gets.chomp
    print "Password: "
    # FIXME: Hide password
    pass = gets.chomp
    # Save details to new file
    userFile = File.new("./user-data/#{user}.txt", "w+")
    userFile.close
    userInfoHash = { 'username' => user, 'realName' => realName, 'pass' => pass, 'balance' => 0.00 }
    updateUserInfoFile(userInfoHash)
    $message = "User created. Please log in."
  else
    $message = ""
  end
  # Return to login menu
  loginMenu
end

# run program
loginMenu()
