#!/bin/bash 

# if on Mac OS, remember to install homebrew and then
# brew install coreutils

PATH_TO_CSV=$(dirname $(greadlink -f '$0'))
# NEO_DB=your/path/to/neo

git rev-list --all --parents > git_rev_list.csv
git log --all --pretty=format:"%H|%cn|%s" > git_notes.csv


echo "
CREATE CONSTRAINT ON (n:Commit) ASSERT n.sha IS UNIQUE;
CREATE CONSTRAINT ON (n:Author) ASSERT n.name IS UNIQUE;

//creating the commits
//first parent
USING PERIODIC COMMIT
LOAD CSV
FROM 'file:${PATH_TO_CSV}/git_rev_list.csv' 
AS line 
FIELDTERMINATOR ' '
WITH line
WHERE line[0] IS NOT NULL
MERGE (a:Commit {sha:line[0]});

//adding author and message
USING PERIODIC COMMIT
LOAD CSV
FROM 'file:${PATH_TO_CSV}/git_notes.csv' 
AS line 
FIELDTERMINATOR '|'
WITH line
MATCH (a:Commit {sha:line[0]})
MERGE (b:Author {name:line[1]})
MERGE (a)<-[:CREATED]-(b)
SET a.message = line[2];

//Adding the notes to the commits
USING PERIODIC COMMIT
LOAD CSV
FROM 'file:${PATH_TO_CSV}/git_rev_list.csv' 
AS line 
FIELDTERMINATOR ' '
WITH line
MERGE (a:Commit {sha:line[0]});

//first parent
USING PERIODIC COMMIT
LOAD CSV
FROM 'file:${PATH_TO_CSV}/git_rev_list.csv' 
AS line 
FIELDTERMINATOR ' '
WITH line
WHERE line[1] IS NOT NULL
MATCH (a:Commit {sha:line[0]}), (b:Commit {sha:line[1]})
MERGE (a)<-[:PARENT_OF]-(b);

//second parent
USING PERIODIC COMMIT
LOAD CSV
FROM 'file:${PATH_TO_CSV}/git_rev_list.csv' 
AS line 
FIELDTERMINATOR ' '
WITH line
WHERE line[2] IS NOT NULL
MATCH (a:Commit {sha:line[0]}), (b:Commit {sha:line[2]})
MERGE (a)<-[:PARENT_OF]-(c);

" > ${PATH_TO_CSV}/git_cypher.cyp

set -e

if [[ -z "$NEO_DB" ]]; then
  echo "Make sure you set \$NEO_DB before running this script"
  echo "you can use 'echo \$(dirname \$(greadlink -f '\$0'))' to find it"
  echo "e.g. (careful with the spaces) export NEO_DB=\"/path/to/neo4j\""
  exit 1
fi

echo "starting up Neo4j instance at ${NEO_DB}"
echo "grabbing data from ${PATH_TO_CSV}/git_cypher.cyp"

${NEO_DB}/bin/neo4j status
if [ $? -ne 0 ]; then
  echo "Neo4j not started. Run ${NEO_DB}/bin/neo4j start before running this script" 
fi

${NEO_DB}/bin/neo4j-shell --file ${PATH_TO_CSV}/git_cypher.cyp

