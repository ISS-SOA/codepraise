#!/bin/bash

RACK_ENV=test rackup -p 9000 &
app_pid=$!

rake spec_accept

kill $app_pid