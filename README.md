# Language specification

Our language is composed of *actions*. Each script has single top-level action. Each action has a return value, with `0` indicating success and everything else failure. There are five different kinds of  action, which are explained in detail below. 

Here's a simple pseudo-BNF of the syntax:

	<action> := <primitive> | <sequence> | <alternative> | <set> | <loop>
	<actions> := "{" <action> [ "\n" <actions> ] "}"
	<sequence> := "do" <actions>
	<alternative> := "try" <actions>
	<set> := "for" <pattern> <action> (currently looks like "for" <pattern> <actions>)
	<loop> := "loop" <action> (same)

## Implementation
A Treenode class has 3 variables: type, value, nodes. Type stands for primitive, sequence etc. Value is the command for primitives and the pattern for sets.
Node is an array that contains the stuff inside the brackets.

## Primitives

A `<primitive>` is anything that's not one of the other actions. It is directly executed as a shell command, including arguments, e.g. `echo -n "hello world"`.

## Sequences

A `<sequence>` is simply a list of actions, separated by line breaks. All actions are executed one after another. If one of the actions fails (i.e. has a return code not equal to zero) the sequence itself fails and any remaining actions are skipped. Example:

	do {
		echo "hello world"
		cat foo.txt > bar.txt
		echo "if foo.txt does not exist, this is never executed"
	}

## Alternatives

An `<alternative>` is also a list of actions, but with different semantics: only the first action is executed. If that fails, the second action is executed. If that fails, the third action is executed and so on. As soon as one of the actions succeeds, the whole block succeeds. In the following example, the directory `foo` is only created if it does not already exist (i.e. `test` fails):

	try {
		test -e foo
		mkdir foo
		echo "could not create directory foo"
	}

## Sets

In a `<set>` an action is executed once for each file specified by a given pattern. If the action fails for one of the files, the whole `<set>` fails and any remaining files are skipped.
	
The `<pattern>` is a unix file path, surrounded by quotation marks, and can include *named wildcards*, surrounded by angle brackets. E.g. the pattern `"~/pics/<year>/<file>.jpg"` contains the wildcards `<year>` and `<file>`.
	
Named wildcards within actions are replaced by their value in the current iteration of the `<set>` that declared them. So the following script would print the names of all files in the current directory (in an undefined order):
	
	for "<file>" do {
		echo <file>
	}
	
To keep things as simple as possible, everything that matches a declared wildcard is replaced by its current value. Anything that might 	syntactically look like a wildcard (e.g. an HTML tag) but hasn't actually been declared as a wildcard, is simply left as-is. For example:

	# declares two wildcards: <dir> and <name>
	for "<dir>/<name>.txt" do {

		# declares the wildcard <pic> 
		# but <dir> is replaced by the current value
		for "<dir>/<pic>.jpg" do {

			# only <name>, <dir> and <pic> are replaced,
			# anything else is left untouched
			echo <h1><name></h1><br/><img src='<dir>/<pic>.jpg'/>
		}
	}
	
## Loops
	
The `<loop>` repeatedly executes as long as the given action is successful and at least one `<primitive>` action is executed per iteration. The return value of the loop is the return value of its action. This means that the only way a loop can terminate with success instead of failure is if its action is a `<set>` that does not specify any files, e.g.
	
	loop {
		for "" do {
			echo "never executed"
		}
	}
	
## Miscellaneous

- Any line beginning with `#` is a comment (there are no inline comments).
- Leading and trailing whitespace is ignored. (I guess extraneous whitespace between keywords can also be ignored, but primitive statements have to be kept intact.)
