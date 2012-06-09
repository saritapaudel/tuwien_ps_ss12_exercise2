class TreeNode
  attr_accessor :label, :nodes 

  def initialize(label)
  @label = label
  @nodes = Array.new
  end

  def addnode(node)
  @nodes.push node
  end

  def printout
  print label, "("
  @nodes.each { |node|
  node.printout
  }
  print ")"
  end

end

class Interpreter
	attr_accessor :query, :rootnode
 
  def initialize()
  @query = String.new
  @rootnode = TreeNode.new("rootnode")
  end

  def getfrominput#Get the query from the command line input
  puts "Please enter your query!"
  input = gets
  input.chomp!
  @query.concat(input)
  createtree(@rootnode)
  end

  def getfromfile(path)#Get the query from a file
  file = File.open(path, "rb")
  @query = file.read
  createtree(@rootnode)
  end

  def createtree(currentnode, query = nil)#Make a tree from the commands
  command = String.new
  if(query == nil)
	query = @query
	end
  i = 0
  while i < query.size do
	if(query[i] == 59)#59 stands for ;
		currentnode.addnode(TreeNode.new(command))
		command = String.new

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
		fornode = TreeNode.new(condition)
		createtree(fornode, body)
		currentnode.addnode(fornode)

	else
		command.concat(query[i])
	end #if
	i += 1
  end #while
  end #createtree


  def runquery
  puts(@query)
  end

  def printtree
  @rootnode.printout
  end

end

main = Interpreter.new
if(ARGV[0] == nil) 
	main.getfrominput
else
	main.getfromfile(ARGV[0])
	end
#main.runquery
main.printtree


