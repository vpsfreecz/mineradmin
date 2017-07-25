# MinerAdmin Core
An Elixir project implementing public API and business logic of MinerAdmin.

## Applications
The project is split into multiple applications, so that each node in the
cluster runs only what it needs:

 - Base - contains migrations, schemas, functions for database access and logic
   that is common for all nodes
 - Model - for now, should run exactly once in a cluster
 - Cluster - simple app that ensures that nodes within the cluster are connected
 - Miner - application running on all worker nodes, serving as an interface
   to Minerd
 - API - public API, uses `model` and `base`
