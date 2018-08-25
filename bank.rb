# Davo's banking app with basic functionality

# Import Hash Helper file
require_relative 'readWriteHashes.rb'

# assign global variables
$message = ""

def login_menu
  system('clear')
  display_login
  print "Username: "
  user = gets.chomp
  # FIXME: Check if user exists
  if File.file?("./user-data/#{user}.txt")
    puts "User Exists"
    userHashes = read_from_file("./user-data/#{user}.txt")
    userInfoHash = userHashes.first
    # puts userHashes.first
    print "Password: "
    # FIXME: Hide password
    pass = gets.chomp
    if pass == userInfoHash['pass']
      puts "Password correct"
    else
      puts "Password incorrect"
    end
    userInfoHash['balance'] = userInfoHash['balance']
    $message = "Welcome #{userInfoHash['realName']}"
    main_menu(userInfoHash)
  else
    create_new_user
  end
end

def main_menu(userInfoHash)
  system('clear')
  display_menu
  display_msg
  print "Choose Option (1-4): "
  input = gets.chomp
  case input
  # View Balance
  when "1"
    $message = "Balance: $%.2f" % userInfoHash['balance']
    main_menu(userInfoHash)
  # Deposit Money
  when "2"
    print "How much to deposit: $"
    amount = get_amount
    add_transaction(amount, userInfoHash)
    $message = "Succesfully Deposited $%.2f" % amount
    $message += "\nNew Balance: $%.2f" % userInfoHash['balance']
    main_menu(userInfoHash)
  # Withdraw Money
  when "3"
    print "How much to withdraw: $"
    amount = get_amount
    add_transaction(-amount, userInfoHash)
    $message = "Succesfully Withdrew $%.2f" % amount
    $message += "\nNew Balance: $%.2f" % userInfoHash['balance']
    main_menu(userInfoHash)
  # View Transactions
  when "4"
    view_transactions(userInfoHash)
  # Exit
  when "5"
    exit
  else
    $message = "ERROR: Invalid selection!"
    main_menu(userInfoHash)
  end
end

# Prints main menu to screen using ASCII art :P
def display_menu
  puts "-----------------------------"
  puts "|     Davo's Banking App    |"
  puts "-----------------------------"
  puts "|                           |"
  puts "| 1) View Balance           |"
  puts "| 2) Deposit Money          |"
  puts "| 3) Withdraw Money         |"
  puts "| 4) Transaction History    |"
  puts "| 5) Exit                   |"
  puts "|                           |"
  puts "-----------------------------"
  display_msg
end

# More super stylish design skills
def display_login
  puts "-----------------------------"
  puts "|     Davo's Banking App    |"
  puts "-----------------------------"
  puts "|                           |"
  puts "|                           |"
  puts "|   Please login            |"
  puts "|      to cointinue...      |"
  puts "|                           |"
  puts "|                           |"
  puts "|                           |"
  puts "-----------------------------"
  display_msg
end

def display_msg
  if $message != ""
    puts $message
    puts "-----------------------------"
  end
  $message = ""
end


# get input amount from user and check for errors
def get_amount
  amount = gets.chomp.to_f
  if amount < 0
    system('clear')
    $message = "ERROR: Must be positive number"
  end
  amount
end

def update_user_info_file(userInfoHash)
  # See for more on Open method options:  https://ruby-doc.org/core-2.5.1/IO.html#method-c-new
  path = './user-data/' + userInfoHash['username'] + '.txt'
  File.open(path, 'w') do |f|
    f.puts hash_to_json(userInfoHash)
    f.close
  end
end

def update_balance(amount, userInfoHash)
  # check if withdrawing and there is enough funds
  if (userInfoHash['balance'] + amount) < 0
    system('clear')
    $message = "ERROR: Not enough funds"
    main_menu(userInfoHash)
  else
    userInfoHash['balance'] += amount.round(2)
    update_user_info_file(userInfoHash)
  end
end

def add_transaction(amount, userInfoHash)
  update_balance(amount, userInfoHash)
  # Check if transaction file exits
  if File.file?("./user-data/#{userInfoHash['username']}_trans.txt")
    puts "Transaction File exists"
  else
    puts "No Transaction File"
    # Create transaction file if doesn't exist
    transFile = File.new("./user-data/#{userInfoHash['username']}_trans.txt", "w")
    transFile.close
  end
  transHash = { 'transTime' => Time.now, 'amount' => amount, 'balance' => userInfoHash['balance'] }
  path = './user-data/' + userInfoHash['username'] + '_trans.txt'
  append_to_file(path, transHash)
end

def view_transactions(userInfoHash)
  path = './user-data/' + userInfoHash['username'] + '_trans.txt'
  transHashArray = read_from_file(path)
  puts transHashArray
  puts "Press enter to continue "
  gets
end


def create_new_user
  system('clear')
  $message = "ERROR: User not found"
  display_login
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
    userFile = File.new("./user-data/#{user}.txt", "w")
    userFile.close
    userInfoHash = { 'username' => user, 'realName' => realName, 'pass' => pass, 'balance' => 0.00 }
    update_user_info_file(userInfoHash)
    $message = "User created. Please log in."
  else
    $message = ""
  end
  # Return to login menu
  login_menu
end

# run program
login_menu()
