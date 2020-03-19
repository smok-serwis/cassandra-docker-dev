cassandra-docker-dev
====================

Have you ever been in a situation where your project
needed a quick Cassandra, but writing it a Dockerfile
proved too cumbersome? **cassandra-docker-dev** to the
rescue!

# Usage

Place your CQL file, named `schema.cql` in the same 
directory in which you have placed your Dockerfile,
containing a single line:

```dockerfile
FROM smok-serwis/cassandra-dev-docker
```

This schema will be loaded and the resulting image 
will be of a Cassandra 3.0.20 with preloaded schema.

Thank you!