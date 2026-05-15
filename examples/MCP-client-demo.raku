#!/usr/bin/env raku
use v6.d;

use lib <. lib>;
use MCP::Client;

my $python = $*HOME ~ '/miniforge3/envs/ADK13/bin/python';
my $mcp-server-file =  $*CWD ~ '/resources/simple_mcp_server.py';

die "Cannot find Python executable ⎡$python⎦." unless $python.IO.f;
die "Cannot find MCP server file ⎡$mcp-server-file⎦." unless $mcp-server-file.IO.f;

note "Using the Python executable ⎡$python⎦.";
note "Using the MCP server file ⎡$mcp-server-file⎦.";

my Bool:D $echo = True;
my Numeric:D $sleep = 0.7;
my $client = MCP::Client.new(:$echo, :$sleep);

say $client.start([$python, '-i', $mcp-server-file]);

$client.initialize();

.say for |$client.list-tools();

$client.kill;