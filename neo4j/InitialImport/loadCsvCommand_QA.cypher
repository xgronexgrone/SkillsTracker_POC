// Pull the distinct skills and merge them
// Design decision here: we want name1 to be unique across the board.
// This in order to distinguish between for example QA/Python and Engineering/Python.
// Thus we will use the naming convention CLASS/SKILL for name1
// Name2 on the other hand will be just SKILL

LOAD CSV FROM 'file:///QA.csv' AS headerLine
WITH headerLine LIMIT 1
WITH headerLine, apoc.coll.indexOf(headerLine, 'Current Role at Modus') + 1 AS startSkill,
apoc.coll.indexOf(headerLine, 'Are there any other relevant technologies you would like to list?') -1 AS endSkill
UNWIND RANGE(startSkill, endSkill) AS i
WITH i AS i, apoc.text.capitalize(replace(headerLine[i],'Please rate your level of expertise with ','')) AS skill
WITH i AS i, 'qa/'+ toLower(skill) AS name1, skill AS name2
MERGE (s:Skill {name1: name1})
SET s:TechnicalSkill:QASkill, s.name2 = name2
RETURN s.name1
ORDER BY s.name1;

//  Pull the distinct persons and merge them
LOAD CSV WITH HEADERS FROM 'file:///QA.csv' AS line
WITH DISTINCT toLower(line.Username) AS email 
MERGE (p:Person {email: email})
SET p.firstname = '', p.lastname = ''
RETURN p.email
ORDER BY p.email;

//  Pull the distinct relations and merge them too
LOAD CSV FROM 'file:///QA.csv' AS headerLine
WITH headerLine LIMIT 1
WITH headerLine, apoc.coll.indexOf(headerLine, 'Current Role at Modus') + 1 AS startSkill,
apoc.coll.indexOf(headerLine, 'Are there any other relevant technologies you would like to list?') -1 AS endSkill
LOAD CSV FROM 'file:///QA.csv' AS dataLine
WITH headerLine, dataLine, startSkill, endSkill SKIP 1
UNWIND RANGE(startSkill, endSkill) AS i
WITH toLower(dataLine[1]) as person_email, 'qa/' + toLower(replace(headerLine[i],'Please rate your level of expertise with ','')) as skill_name1, coalesce(toInt(dataLine[i]),1) AS expertiseLevel
WITH person_email, skill_name1, expertiseLevel
WHERE expertiseLevel >= 2
MATCH(p: Person {email:person_email})
MATCH(s: Skill {name1:skill_name1})
MERGE (p)-[ps:HAS_SKILL]->(s)
SET ps.expertiseLevel = expertiseLevel - 1
RETURN p.email, s.name1, ps.expertiseLevel;