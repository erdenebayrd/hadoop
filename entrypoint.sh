#!/bin/bash
# Start SSH daemon
service ssh start

# Execute the passed command
exec "$@"