#!/usr/bin/env raku
use v6.d;

#use lib <. lib>;
use LLM::Functions;
use LLM::Prompts;
use Text::SubParsers;

use MCP::Client;

my $python = $*HOME ~ '/miniforge3/envs/ADK13/bin/python';
my $mcp-server-file =  $*CWD ~ '/resources/simple_mcp_server.py';

die "Cannot find Python executable ⎡$python⎦." unless $python.IO.f;
die "Cannot find MCP server file ⎡$mcp-server-file⎦." unless $mcp-server-file.IO.f;

note "Using the Python executable ⎡$python⎦.";
note "Using the MCP server file ⎡$mcp-server-file⎦.";

my Bool:D $echo = False;
my Numeric:D $sleep = 1;
my $client = MCP::Client.new(:$echo, :$sleep);

say $client.start([$python, '-i', $mcp-server-file]);

$client.initialize();

say '=' x 100;
say 'MCP tools';
say '-' x 100;

my @mcp-tools = |$client.list-tools();

.say for |@mcp-tools;

my @tools = @mcp-tools.map({ $client.to-llm-tool($_) });

say '=' x 100;
say 'LLM::Tool objects';
say '-' x 100;

.say for |@tools;

say '=' x 100;
say 'LLM synthesis';
say '-' x 100;

my $conf = llm-configuration('ChatGPT', model => 'gpt-4.1-mini', :@tools);

#say llm-synthesize('Generate a list of 12 random common words.', e => $conf);
say llm-synthesize('What is the current datetime?.', e => $conf);


say '-' x 100;

my @res = |llm-synthesize([
    'Generate a list of 6 random bulshit jobs.',
    llm-prompt('NothingElse')('JSON')
    ],
    e => $conf,
    form => sub-parser('JSON'):drop
);

.say for |@res;

## Kill MCP sever process
$client.kill;