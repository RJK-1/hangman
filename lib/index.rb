require 'colorize'

class Game
  attr_accessor :word, :moves_left, :used_letters, :correct_letters, :blanked_word
  def initialize
    @word = random_word
    @blanked_word = blank_word(@word)
    @moves_left = 10
    @used_letters = []
    @correct_letters = []
  end

  def random_word
    word = File.readlines('5desk.txt').sample.downcase.chomp
    word.length.between?(5,12) ? word : random_word
  end
  
  def blank_word(word)
    Array.new(word.length, '_').join
  end

  def moves_remaining
    if @moves_left >= 1
      puts "Moves remaining: #{@moves_left}"
    else
      puts "You are out of moves! The word was #{@word}"
      exit
    end
  end

  def check_move(letter)
    @moves_left -= 1
    if @word.include? letter
      puts "Your letter is in the word!".yellow.bold
      @correct_letters << letter
      update_blanks(letter)
      return
    else
      puts "Your letter isn't in the word".red.bold
      @used_letters << letter
    end
  end

  def update_blanks(letter)
    indexes = (0 ... @word.length).find_all { |i| @word[i,1] == "#{letter}" }
    indexes.each { |i| @blanked_word[i] = letter}
  end
end

class PlayGame
  def initialize(game)
    @game = game
  end

  def start_game
    puts "Welcome to Hangman!".red.bold
    puts <<~HEREDOC
    You have 8 moves to guess the hidden word!
    The word will be between 5 and 12 letters long.
    Your remaining moves and incorrect letters 
    will be displayed. 
    HEREDOC
    puts "Press 1 to start a new game, or 2 to load an existing game"
    choice = gets.chomp
    if choice == '1'
      guess_letter
    elsif choice == '2'
      #load game
    else
      puts "Invalid Choice"
    end
  end

  def guess_letter
    if @game.moves_left > 0
      puts @game.blanked_word
      puts "Guess a letter:"
      letter = gets.chomp.downcase
      verify_letter(letter)
    end
  end

  def verify_letter(letter)
    if @game.used_letters.include?(letter) || @game.correct_letters.include?(letter)
      puts "You have already used this letter!".red
      guess_letter
    else
      if letter.match?(/[a-z]/) && letter.length == 1
        check_move(letter)
      else
        puts "Please choose a single letter only"
        guess_letter
      end
    end
  end

  def check_move(letter)
    @game.check_move(letter)
    check_win
    @game.moves_remaining
    puts "Used letters: #{@game.used_letters.join(', ')}"
    guess_letter
  end

  def check_win
    if @game.blanked_word.include?('_')
      return
    else
      puts "You have won the game!".yellow.bold
      exit
    end
  end
end

game = Game.new
playgame = PlayGame.new(game)
playgame.start_game