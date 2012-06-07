class Interpreter
	attr_accessor :query
 
 def initialize()
 @query = String.new
 end

 def getfrominput#Get the query from the command line input
  puts "Please enter your query!"
  input = gets
  input.chomp!
  @query.concat(input)
 end

 def getfromfile(path)#Get the query from a file
 File.open(path).each { |line|
    @query.concat(line)
 }
 end

 def runquery
 puts(@query)
 end

end

main = Interpreter.new
if(ARGV[0] == nil) 
	main.getfrominput
else
	main.getfromfile(ARGV[0])
	end
main.runquery

