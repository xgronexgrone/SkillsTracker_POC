// Delete all
MATCH (n) DETACH DELETE n;

// Delete relationships only
MATCH (a)-[hs:HAS_SKILL]->(b) DETACH DELETE hs;