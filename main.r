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
  COMMENT = "#"
 
  def initialize()
  @query = String.new
  @rootnode = TreeNode.new("root", "rootnode")
  end

  def getfrominput#Get the query from the command line input - just for fun
  puts "Please enter your query!"
  input = gets
  input.chomp!
  @query.concat(input)
  createtree(@rootnode)
  end

  def getfromfile(path)#Get the query from a file
  file = File.open(path, "r:ascii")#Hopefully this makes life easier
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

	if(query[i] == COMMENT)#Skip line if it's a comment
	i = nextline(i)

	elsif(query[i, 3].upcase.eql? "DO ")
		body = String.new #The primitves inside the sequence
		brackets = 0
		while !(query[i] == "{") do#Go to the position of the opening bracket
		i += 1
		end
		while brackets >= 0 do#Get the stuff inside the brackets
			i += 1
			if(query[i] == "{")
			  brackets += 1
			elsif(query[i] == "}")
			  brackets -= 1
			end

			if(brackets >= 0)
			  body.concat(query[i])
			end
		end #while

		#Add the tree node and process the body
		donode = TreeNode.new("sequence", "do")
		createtree(donode, body)
		currentnode.addnode(donode)


	elsif(query[i, 4].upcase.eql? "TRY ")
		body = String.new #The primitves inside the sequence
		brackets = 0
		while !(query[i] == "{") do#Go to the position of the opening bracket
		i += 1
		end
		while brackets >= 0 do#Get the stuff inside the brackets
			i += 1
			if(query[i] == "{")
			  brackets += 1
			elsif(query[i] == "}")
			  brackets -= 1
			end

			if(brackets >= 0)
			  body.concat(query[i])
			end
		end #while

		#Add the tree node and process the body
		trynode = TreeNode.new("alternative", "try")
		createtree(trynode, body)
		currentnode.addnode(trynode)

	elsif(query[i, 4].upcase.eql? "FOR ")
		value = String.new
		body = String.new #The primitves inside the sequence
		brackets = 0

		while !(query[i] == "\"") do#Go to the position wildcards
		i += 1
		end
		i += 1
		while !(query[i] == "\"") do
		value.concat(query[i])
		i += 1
		end

		while !(query[i] == "{") do#Go to the position of the opening bracket
		i += 1
		end
		while brackets >= 0 do#Get the stuff inside the brackets
			i += 1
			if(query[i] == "{")
			  brackets += 1
			elsif(query[i] == "}")
			  brackets -= 1
			end

			if(brackets >= 0)
			  body.concat(query[i])
			end
		end #while

		#Add the tree node and process the body
		fornode = TreeNode.new("set", value)
		createtree(fornode, body)
		currentnode.addnode(fornode)


	elsif(query[i, 5].upcase.eql? "LOOP ")
		body = String.new #The primitves inside the sequence
		brackets = 0
		while !(query[i] == "{") do#Go to the position of the opening bracket
		i += 1
		end
		while brackets >= 0 do#Get the stuff inside the brackets
			i += 1
			if(query[i] == "{")
			  brackets += 1
			elsif(query[i] == "}")
			  brackets -= 1
			end

			if(brackets >= 0)
			  body.concat(query[i])
			end
		end #while

		#Make the for loop tree
		loopnode = TreeNode.new("loop", "loop")
		createtree(loopnode, body)
		currentnode.addnode(loopnode)

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

  def ignorespaces(pos)#Jump to the next non space character
  while query[pos] == SPACE do
    pos += 1
    end
  return pos
  end

  def nextline(pos)#Jump to the next end of line character
  while query[pos] != ENDLINE do
    pos += 1
    end
  return pos
  end

  def printtree#Test
  @rootnode.printout
  end

end

class Processtree

  def initialize(rootnode)
  @rootnode = rootnode
  end

  def evaluate(node = @rootnode)
  node.nodes.each { |act|

  if(act.type.eql? "primitive")
     execute(act.value)
  elsif(act.type.eql? "sequence")
     donode(act)
  elsif(act.type.eql? "alternative")
     trynode(act)
  elsif(act.type.eql? "set")
     loopnode(act)
  elsif(act.type.eql? "loop")
     fornode(act)
  end

  act.printout#test
  }

  end

  def validate
  #TODO optional (who needs this? >:])

  end

  def execute(command)
  #TODO executes a primitive
  end

  def donode(node)
  #TODO
  end

  def trynode(node)
  #TODO
  end

  def loopnode(node)
  #TODO
  end

  def fornode(node)
  #TODO
  end


end


#The main script
main = Interpreter.new
if(ARGV[0] == nil) 
	main.getfrominput
else
	main.getfromfile(ARGV[0])
	end
prc = Processtree.new(main.rootnode)
prc.evaluate

