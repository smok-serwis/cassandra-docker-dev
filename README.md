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
FROM smokserwis/cassandra-dev-docker
```

This schema will be loaded and the resulting image 
will be of a Cassandra 3.0.20 with preloaded schema.

Thank you!

## I have the schema in multiple files!

Don't worry, `cassandra-docker-dev` has you covered. Just add the following to your Dockerfile:

```
ADD schema_extra /tmp/schema_extra.cql
```

The file has to be named /tmp/schema*.cql, since this is what `cassandra-docker-dev` will try to
load. You need to add them manually, though, they won't be added automatically like `schema.cql`. 
Of course you still need to place `schema.cql` so place there your main schema, with the schemas
for tools named like `schema_jaeger.cql`.

