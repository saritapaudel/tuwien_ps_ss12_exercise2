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
  File.open(path).each { |line|
    @query.concat(line)
  }
  createtree(@rootnode)
  end

  def createtree(currentnode)#Make a tree from the commands
  command = String.new
  i = 0
  while i < @query.size do
	if(@query[i] == 59)#Stands for ;
		currentnode.addnode(TreeNode.new(command))
		command = String.new
	else
		command.concat(@query[i])
	end
	i += 1
  end
  end


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


