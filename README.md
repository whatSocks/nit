nit
===

First type in `git log --neo`

Actually, no. That was a joke. 
I couldn't sleep so I made this.

if you haven't done so already, `brew install coreutils`.

place the sh file in a git repo, make sure your local db is turned on, and press the `sh make_cyp.sh` button on your keybpard.

That'll create some Neo4j .cyp that will pump your git commit and author logs into your local db via the neo4j-shell. 

Make sure to edit the .sh file to point to your appropriate whosiwhatsits:

```
NEO_DB=your/path/to/neo
```

but for realz bro, this repo needs a lot of work. I should just stick to 

`git log --graph --decorate --oneline --all`

but then I'd be able to sleep. 

mapping git commits and authors into a neo4j db

![webstack](graph_pic.png)

This is a picture of one of my other repos. Three contributors, relatively few commits.

