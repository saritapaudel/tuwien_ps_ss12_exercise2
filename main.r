class TreeNode
  attr_accessor :type, :value, :nodes 

  def initialize(type, value)
  @type = type
  @value = value
  @nodes = Array.new
  end

  def addnode(node)
  @nodes.push node
  end

  #Only test purpose
  def printout
  print value, "("
  @nodes.each { |node|
  node.printout
  }
  print ")"
  end

end

class Interpreter
	attr_accessor :query, :rootnode

  #ascii constants
  ENDLINE = 10.chr
  SPACE = 32.chr
  COMMENT = "#"#hash
 
  def initialize()
  @query = String.new
  @rootnode = TreeNode.new("root", "rootnode")
  end

  def getfrominput#Get the query from the command line input
  puts "Please enter your query!"
  input = gets
  input.chomp!
  @query.concat(input)
  createtree(@rootnode)
  end

  def getfromfile(path)#Get the query from a file
  file = File.open(path, "r:ascii")#Trying to prevent ambiguity by using ascii encoding
  @query = file.read
  createtree(@rootnode)
  end

  def createtree(currentnode, query = nil)#Make a tree from the commands
  command = String.new
  if(query == nil)#If no query string supplied it is the tree node
	query = @query
	end
  i = 0

  while i < query.size do
	i = ignorespaces(i)

	if(query[i] == COMMENT)
	i = nextline(i)
	elsif(query[i, 3].upcase.eql? "FOR")
	     #Process "for" loop
		condition = String.new #The conditions of the foor loop
		body = String.new #The commands inside the loop
		while !(query[i] == 123) do#Get the conditions, ie. push everything until the bracket
			condition.concat(query[i])
			i += 1
		end #while
		brackets = 0
		while brackets >= 0 do#Find the closing bracket
			i += 1
			if(query[i] == 123)
			  brackets += 1
			elsif(query[i] == 125)
			  brackets -= 1
			end

			if(brackets >= 0)
			  body.concat(query[i])
			end
		end #while
		#Make the for loop tree
		fornode = TreeNode.new("loop", condition)
		createtree(fornode, body)
		currentnode.addnode(fornode)

	else#Primitive
		command = String.new
		while !(query[i] == ENDLINE) do
		  command.concat(query[i])
		  i += 1
		  end
		if(command.size > 0)#skip empty lines
		  currentnode.addnode(TreeNode.new("primitive", command))
		  end

	end #if
	i += 1
  end #while
  end #createtree

  def ignorespaces(pos)#Jump to the next character
  while query[pos] == SPACE do
    pos += 1
    end
  return pos
  end

  def nextline(pos)#Jump to the next line
  while query[pos] != ENDLINE do
    pos += 1
    end
  return pos
  end

  def printtree#Test
  @rootnode.printout
  end

end

main = Interpreter.new
if(ARGV[0] == nil) 
	main.getfrominput
else
	main.getfromfile(ARGV[0])
	end
main.printtree

