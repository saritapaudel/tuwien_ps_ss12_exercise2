require "rbconfig"

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
  TAB = 9.chr
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

	if(query[i] == COMMENT)#Skip line if it's a comment
  	  while query[i] != ENDLINE do#Jump to the next end of line character
	    i += 1
	    end

	elsif(query[i, 3].upcase.eql? "DO ")
		body = String.new #The primitves inside the sequence
		brackets = 0
		while query[i] != "{" do#Go to the position of the opening bracket
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
		while query[i] != "{" do#Go to the position of the opening bracket
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

		while query[i] != "\"" do#Go to the position wildcards
		i += 1
		end
		i += 1
		while query[i] != "\"" do
		value.concat(query[i])
		i += 1
		end

		while query[i] != "{" do#Go to the position of the opening bracket
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
		while query[i] != "{" do#Go to the position of the opening bracket
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

	elsif((query[i] != SPACE) && (query[i] != ENDLINE) && (query[i] != TAB))#Primitive
		command = String.new
		while query[i] != ENDLINE do
		  command.concat(query[i])
		  i += 1
		  end
		if(command.size > 0)#skip empty lines
		  currentnode.addnode(TreeNode.new("primitive", command))
		  end

	end #if
	i += 1#Move to next character
  end #while
  end #createtree

  def printtree#Test
  @rootnode.printout
  end

end

class Processtree

  def initialize(rootnode)
  @rootnode = rootnode
  @os = RbConfig::CONFIG["target_os"]
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
     fornode(act)
  elsif(act.type.eql? "loop")
     loopnode(act)
  end

  #act.printout#test
  }

  end

  def execute(cmd) #Primitive
  #executes a shell command
  puts cmd
  value = system( cmd )
  puts value
  return value #Optional because by default Ruby returns the value of the last statement
  end

  def donode(node) #Sequence
  #execute all actions but break if one returns false
  puts "Sequence: "
  node.nodes.each { |act|
  if(!execute(act.value))
	return false
  end
  }
  return true
  end

  def trynode(node) #Alternative
  #same as sequence except it breaks if one returns true
  puts "Alternative: "
  node.nodes.each { |act|
  if(execute(act.value))
	return true
  end
  }
  return false
  end

  def wildcardexec(cmd)
  
  end

  def fornode(node) #Set
  #TODO
  wildcard = node.value
  Dir.foreach(Dir.pwd) do |entry|#List of files in this directory
   puts entry
   end
  end# fornode

  def loopnode(node) #Loop
  #executes until true and there is one successfull primitive
  success = true
  while success == true do
  node.nodes.each { |act|
  if(act.type.eql? "primitive")
     success = execute(act.value)
  elsif(act.type.eql? "sequence")
     success = donode(act)
  elsif(act.type.eql? "alternative")
     success = trynode(act)
  elsif(act.type.eql? "set")
     success = fornode(act)
  elsif(act.type.eql? "loop")
     success = loopnode(act)
  end
  if(!success)
    return false
    end
  }
  end# while
  return true
  end# loopnode


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

