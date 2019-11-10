// All
MATCH (n) DETACH DELETE n;

// Relationships only
MATCH (a)-[hs:HAS_SKILL]->(b) DETACH DELETE hs;