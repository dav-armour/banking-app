# Davo's banking app with basic functionality
# Run 'sudo gem install json' to install the JSON gem
require 'json'
require 'date'
# Nick's hash helper file
require_relative 'readWriteHashes.rb'

# assign global variables
$message = ''

def login_menu
  system('clear')
  display_login
  $message = ''
  print 'Username: '
  user = gets.chomp
  if File.file?("./user-data/#{user}.txt")
    user_hashes = read_from_file("./user-data/#{user}.txt")
    user_info_hash = user_hashes.first
    print 'Password: '
    # FIXME: Hide password
    pass = gets.chomp
    if pass != user_info_hash['pass']
      $message = 'Password incorrect'
      login_menu
    end
    user_info_hash['balance'] = user_info_hash['balance']
    $message = "Welcome #{user_info_hash['real_name']}"
    main_menu(user_info_hash)
  else
    create_new_user
  end
end

def main_menu(user_info_hash)
  system('clear')
  display_menu
  display_msg
  print 'Choose Option (1-5): '
  input = gets.chomp
  case input
  # View Balance
  when '1'
    $message = 'Balance: $%.2f' % user_info_hash['balance']
    main_menu(user_info_hash)
  # Deposit Money
  when '2'
    print 'How much to deposit: $'
    amount = get_amount
    add_transaction(amount, user_info_hash)
    $message = 'Succesfully Deposited $%.2f' % amount
    $message += '\nNew Balance: $%.2f' % user_info_hash['balance']
    main_menu(user_info_hash)
  # Withdraw Money
  when '3'
    print 'How much to withdraw: $'
    amount = get_amount
    add_transaction(-amount, user_info_hash)
    $message = 'Succesfully Withdrew $%.2f' % amount
    $message += '\nNew Balance: $%.2f' % user_info_hash['balance']
    main_menu(user_info_hash)
  # View Transactions
  when '4'
    view_transactions(user_info_hash)
    main_menu(user_info_hash)
  # Exit
  when '5'
    system('clear')
    exit
  else
    $message = 'ERROR: Invalid selection!'
    main_menu(user_info_hash)
  end
end

# Prints main menu to screen using ASCII art :P
def display_menu
  puts '-------------------------------------------------'
  puts "|              Davo's Banking App               |"
  puts '-------------------------------------------------'
  puts '|                                               |'
  puts '|             1) View Balance                   |'
  puts '|             2) Deposit Money                  |'
  puts '|             3) Withdraw Money                 |'
  puts '|             4) Transaction History            |'
  puts '|             5) Exit                           |'
  puts '|                                               |'
  puts '-------------------------------------------------'
  display_msg
end

# More super stylish design skills
def display_login
  puts '-------------------------------------------------'
  puts "|              Davo's Banking App               |"
  puts '-------------------------------------------------'
  puts '|                                               |'
  puts '|                                               |'
  puts '|              Please login                     |'
  puts '|                  to cointinue...              |'
  puts '|                                               |'
  puts '|                                               |'
  puts '|                                               |'
  puts '-------------------------------------------------'
  display_msg
end

def display_msg
  if $message != ''
    puts $message
    # puts "---------------------------------------------"
  end
  $message = ''
end

# get input amount from user and check for errors
def get_amount
  amount = gets.chomp.to_f
  if amount < 0
    system('clear')
    $message = 'ERROR: Must be positive number'
  end
  amount
end

def update_user_info_file(user_info_hash)
  # See for more on Open method options:  https://ruby-doc.org/core-2.5.1/IO.html#method-c-new
  path = './user-data/' + user_info_hash['username'] + '.txt'
  File.open(path, 'w') do |f|
    f.puts hash_to_json(user_info_hash)
  end
end

def update_balance(amount, user_info_hash)
  # check if withdrawing and there is enough funds
  if (user_info_hash['balance'] + amount) < 0
    system('clear')
    $message = 'ERROR: Not enough funds'
    main_menu(user_info_hash)
  # Limit balances to < $1 million to not mess up display
  elsif (user_info_hash['balance'] + amount) >= 1_000_000
    system('clear')
    $message = 'ERROR: Your too rich for this bank.'
    $message += '\nOnly supports balances below $1 million'
    main_menu(user_info_hash)
  else
    user_info_hash['balance'] += amount.round(2)
    update_user_info_file(user_info_hash)
  end
end

def add_transaction(amount, user_info_hash)
  update_balance(amount, user_info_hash)
  # Create transaction file if doesn't exist
  path = "./user-data/#{user_info_hash['username']}_trans.txt"
  File.new(path, 'w').close unless File.file?(path)
  trans_hash = {
    'transTime' => Time.now,
    'amount' => amount,
    'balance' => user_info_hash['balance']
  }
  path = './user-data/' + user_info_hash['username'] + '_trans.txt'
  append_to_file(path, trans_hash)
end

def view_transactions(user_info_hash)
  system('clear')
  puts '-------------------------------------------------'
  puts '|              Transaction History              |'
  puts '-------------------------------------------------'
  puts '|                                               |'
  path = './user-data/' + user_info_hash['username'] + '_trans.txt'
  # Check if transaction file exists
  if File.file?(path)
    trans_hash_array = read_from_file(path)
    # Loop through all transactions
    puts '|  Time                Amount       Balance     |'
    trans_hash_array.last(5).each do |trans_hash|
      # make time look pretty
      time = DateTime.strptime(trans_hash['transTime'], '%Y-%m-%d %H:%M:%S %z')
      time_pretty = time.strftime('%d/%m/%Y %H:%M')
      # Show two decimal places for money
      if trans_hash['amount'] < 0
        amount = '-$%.2f' % trans_hash['amount'].abs
      else
        amount = ' $%.2f' % trans_hash['amount']
      end
      # add padding
      amount += ' ' while amount.length < 11
      balance = '$%.2f' % trans_hash['balance']
      # add padding
      balance += ' ' while balance.length < 10
      puts "|  #{time_pretty}   #{amount}   #{balance}  |"
    end
    # add padding
    (5 - trans_hash_array.last(5).length).times do
      puts '|                                               |'
    end
  else
    puts '|             No Transactions Found!            |'
    5.times { puts '|                                               |' }
  end
  puts '-------------------------------------------------'
  print 'Press enter to continue '
  gets
end

def create_new_user
  system('clear')
  $message = 'ERROR: User not found'
  display_login
  print 'Create new user? (Y/N): '
  answer = gets.chomp
  if answer == 'y' || answer == 'Y'
    print 'Username: '
    user = gets.chomp
    print 'Real Name: '
    real_name = gets.chomp
    print 'Password: '
    # FIXME: Hide password
    pass = gets.chomp
    # Save details to new file
    user_file = File.new("./user-data/#{user}.txt", 'w')
    user_file.close
    user_info_hash = {
      'username' => user,
      'real_name' => real_name,
      'pass' => pass,
      'balance' => 0.00
    }
    update_user_info_file(user_info_hash)
    $message = 'User created. Please log in.'
  else
    $message = ''
  end
  # Return to login menu
  login_menu
end

# run program
login_menu
