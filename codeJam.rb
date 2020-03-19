require 'colorize'

LATENCY_PERIOD = 6
class Citizen
  attr_accessor :posX, :posY, :age, :infected, :infected_at, :recovered
  def initialize
    @posX = rand(25)
    @posY = rand(25)
    @age = rand(100)
    @infected = false
    @infected_at = 0
    @recovered = false
  end
end

class Simulation
  attr_accessor :citizens, :average_contaminations_day, :date
  def initialize(noCitizens)
    @noCitizens = noCitizens
    @date = 1
    @citizens = Array.new(noCitizens)
    @grid = Array.new(25) { Array.new(25, 0) }

    (0...noCitizens).each do |i|
      citizen = Citizen.new()
      @citizens[i] = citizen
      @grid[citizen.posY][citizen.posX] = citizen
    end
    infect(rand_citizen)
    infect(rand_citizen)
    @average_contaminations_day = 5
    while infected_citizens.length > 0
      to_s  
      sleep(0.3)
      puts "\033[2J"
      virus_progression
      @date += 1
    end
  end

  def infect(citizen)
    citizen.infected = true
    citizen.infected_at = @date
  end

  def infected_citizens
    @citizens.select { |citizen| citizen.infected }
  end

  def contagious_citizens
    infected_citizens.select { |citizen| @date - citizen.infected_at >= 14 }
  end
  
  def kill(citizen)
    @grid[citizen.posY][citizen.posX] = 'X'
  end

  def save(citizen)
    citizen.infected = false
    citizen.infected_at = 0
    citizen.recovered = true
  end

  def virus_progression
    contagious_citizens.each do |citizen|
      time_of_change = 9 + rand(20)
      if (time_of_change <= date - citizen.infected_at)
        # ages from https://virusncov.com/covid-19-age-sex-cases-and-deaths
        percentage = rand(0.0..100.0)
        if citizen.age <= 9
          death_percent = 0
        elsif citizen.age <= 39
          death_percent = 0.2
        elsif citizen.age <= 49
          death_percent = 0.4
        elsif citizen.age <= 59
          death_percent = 1.3
        elsif citizen.age <= 69
          death_percent = 3.6
        elsif citizen.age <= 79
          death_percent = 8.0
        else
          death_percent = 14.8
        end
        if percentage <= death_percent 
          kill(citizen)
        else
          save(citizen)
        end
      else
        (0...@average_contaminations_day).each do
          infectedX = 0
          infectedY = 0
          infectedX = (citizen.posX - 7 + rand(14)) % 25
          infectedY = (citizen.posY - 7 + rand(14)) % 25
          infect(@grid[infectedY][infectedX]) unless (@grid[infectedY][infectedX] == 0 || @grid[infectedY][infectedX] == 'X') || @grid[infectedY][infectedX].recovered
        end
      end
    end
  end

  def rand_citizen
    citizen = 0
    loop do
      citizen = citizens[rand(@noCitizens)]
      break if citizen != 'X'
    end
    citizen
  end

  def to_s
    noDead = 0
    noInfected = 0
    (0...25).each do |y|
      (0...25).each do |x|
        if (@grid[y][x] != 0 && @grid[y][x] != 'X')
          if @grid[y][x].infected
            noInfected += 1
            print @grid[y][x].age.to_s.colorize(:red) 
          elsif @grid[y][x].recovered
            print @grid[y][x].age.to_s.colorize(:green) 
          else 
            print @grid[y][x].age.to_s.colorize(:blue)
          end
        elsif @grid[y][x] == 'X'
          print 'X'.black.on_red
          noDead += 1
        else
          print @grid[y][x]
        end
        print " "
      end
       puts ""
    end
    #print "Percent dead: #{noDead / @noCitizens * 100}%               "
    puts "Infected: #{noInfected}"
    puts "Number of days since beginning: #{date}"
  end
end

puts "
█▀▀ █░█ █▀█ █▄▄   █▀▀ █▀█ █░█ █ █▀▄
█▄▄ █▄█ █▀▄ █▄█   █▄▄ █▄█ ▀▄▀ █ █▄▀
"
newSim = Simulation.new(400)
