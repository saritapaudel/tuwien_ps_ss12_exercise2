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



  def evaluate(node)

  success = false

  if(node.type.eql? "primitive")
     success = execute(node.value)
  elsif(node.type.eql? "sequence")
     success = donode(node)
  elsif(node.type.eql? "alternative")
     success = trynode(node)
  elsif(node.type.eql? "set")
     success = fornode(node)
  elsif(node.type.eql? "loop")
     success = loopnode(node)
  end

  #act.printout#test
  return success
  end


  def start()
  @rootnode.nodes.each { |act|
  evaluate(act)
  }
  end

  def execute(cmd) #Primitive
  #executes a shell command
  #puts cmd
  value = system( cmd )
  #puts value
  return value #Optional because by default Ruby returns the value of the last statement
  end

  def donode(node) #Sequence
  #execute all actions but break if one returns false
  puts "Sequence: "
  node.nodes.each { |act|
  if(!evaluate(act))
	return false
  end
  }
  return true
  end

  def trynode(node) #Alternative
  #same as sequence except it breaks if one returns true
  #puts "Alternative: "
  node.nodes.each { |act|
  if(evaluate(act))
	return true
  end
  }
  return false
  end


  def fornode(node) #Set
  #same as sequence but wildcards are added

  wildcards = Array.new
  starredpath = String.new

  i = 0
  while i < node.value.size do#Create an array of wildcards
    if(node.value[i] == "<")
      i += 1
      wc = String.new
      wc.concat("<")#Opening bracket (if needed)
      while(node.value[i] != ">") do
	wc.concat(node.value[i])
	i += 1
	end# while
      if(wc.size > 0)
        wildcards.push wc
        end# if
      wc.concat(">")#Closing bracket (if needed)
      starredpath.concat("*")#Substitute it with a star
    else
    starredpath.concat(node.value[i])
    end# if
    i += 1
    end# while

  #testprint
  #puts "node value: ", node.value, starredpath, " wildcards: "
  #wildcards.each { |wc|
  #puts wc
  #}
  
   entries = Dir.glob(starredpath).each { |entry|
   #puts entry#testprint

   #Get the current value of wildcards
   values = Array.new
   value = String.new
   i = 0
   j = 0
   while i < starredpath.size do
     if(starredpath[i] == "*" && i < starredpath.size - 1)
	while starredpath[i + 1] != entry[j] do
	  value.concat(entry[j])
	  j += 1
	end# while
	values.push(value)
	value = String.new
	j -= 1
     elsif(starredpath[i] == "*")#Wildcard is at last position
	while j < entry.size do
	  value.concat(entry[j])
	  j += 1
	end# while
	values.push(value)
	value = String.new
	j -= 1
     end# if
     i += 1
     j += 1
   end# while

   node.nodes.each { |act|
     #Substitute the new value
     old = act.value
     i = 0
     while i < wildcards.size do
       act.value = act.value.gsub(wildcards[i], values[i])
       j = 0
       subs = Array.new#Subnodes
       while j < act.nodes.size do
         subs[j] = act.nodes[j].value
         act.nodes[j].value = act.nodes[j].value.gsub(wildcards[i], values[i])
         j += 1
         end
       i += 1
       end# while
     #Evaluate
     evaluate(act)
     #Substitute the old value back
     act.value = old
     j = 0
       while j < act.nodes.size do
         act.nodes[j].value = subs[j]
         j += 1
         end
   }# act

   }# entry

  end# fornode

  def loopnode(node) #Loop
  #executes until true and there is one successfull primitive
  success = true
  i = 0
  number = 0

  while success == true do
  evaluate(node.nodes[i])
  number += node.nodes[i].nodes.size
  i += 1

  if((!success) || (number == 0))
    return false
  elsif(i == node.nodes.size)
    i = 0
    number = 0
  end
  

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
prc.start

