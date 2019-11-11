// Pull the distinct skills and merge them
//LOAD CSV FROM 'file:///DevOps_Database.csv' AS headerLine
LOAD CSV FROM 'https://raw.githubusercontent.com/xgronexgrone/SkillsTracker_POC/master/neo4j/InitialImport/Datasets/DevOps_Database.csv?token=ALCOBTICUD2XM5RYZKBY5BS5ZCS6Y
' AS headerLine
WITH headerLine LIMIT 1
WITH headerLine, apoc.coll.indexOf(headerLine, 'Current Role at Modus') + 1 AS startSkill,
apoc.coll.indexOf(headerLine, 'Do you have any certifications in this area?') -1 AS endSkill
UNWIND RANGE(startSkill, endSkill) AS i
WITH i AS i,  apoc.text.capitalize(headerLine[i]) AS skill
WITH i AS i, 'dodb/'+ toLower(skill) AS name1, skill AS name2
MERGE (s:Skill {name1: name1})
SET s:TechnicalSkill:DevOpsDatabaseSkill, s.name2 = name2
RETURN s.name1
ORDER BY s.name1;

// Pull the distinct persons and merge them
//LOAD CSV WITH HEADERS FROM 'file:///DevOps_Database.csv' AS line
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/xgronexgrone/SkillsTracker_POC/master/neo4j/InitialImport/Datasets/DevOps_Database.csv?token=ALCOBTICUD2XM5RYZKBY5BS5ZCS6Y
' AS line
WITH DISTINCT toLower(line.Username) AS email 
MERGE (p:Person {email: email})
SET p.firstname = '', p.lastname = ''
RETURN p.email
ORDER BY p.email;

// Pull the distinct relations and merge them too
//LOAD CSV FROM 'file:///DevOps_Database.csv' AS headerLine
LOAD CSV FROM 'https://raw.githubusercontent.com/xgronexgrone/SkillsTracker_POC/master/neo4j/InitialImport/Datasets/DevOps_Database.csv?token=ALCOBTICUD2XM5RYZKBY5BS5ZCS6Y
' AS headerLine
WITH headerLine LIMIT 1
WITH headerLine, apoc.coll.indexOf(headerLine, 'Current Role at Modus') + 1 AS startSkill,
apoc.coll.indexOf(headerLine, 'Do you have any certifications in this area?') -1 AS endSkill
//LOAD CSV FROM 'file:///DevOps_Database.csv' AS dataLine
LOAD CSV FROM 'https://raw.githubusercontent.com/xgronexgrone/SkillsTracker_POC/master/neo4j/InitialImport/Datasets/DevOps_Database.csv?token=ALCOBTICUD2XM5RYZKBY5BS5ZCS6Y
' AS dataLine
WITH headerLine, dataLine, startSkill, endSkill SKIP 1
UNWIND RANGE(startSkill, endSkill) AS i
WITH toLower(dataLine[1]) as person_email, 'dodb/' + toLower(headerLine[i]) as skill_name1, coalesce(toInt(dataLine[i]),1) AS expertiseLevel
WITH person_email, skill_name1, expertiseLevel
WHERE expertiseLevel >= 2
MATCH(p: Person {email:person_email})
MATCH(s: Skill {name1:skill_name1})
MERGE (p)-[ps:HAS_SKILL]->(s)
SET ps.expertiseLevel = expertiseLevel - 1
RETURN p.email, s.name1, ps.expertiseLevel;