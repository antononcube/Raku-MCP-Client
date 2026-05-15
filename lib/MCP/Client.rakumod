use v6.d;

use JSON::Fast;
use LLM::Tooling;

class MCP::Client {
    has Str:D $.output = '';
    has Int:D $.next-id = 0;
    has Bool:D $.initialized = False;
    has Numeric:D $.sleep = 1;
    has Bool:D $.echo = False;
    has $.process;
    has $.promise;
    
    method start(@cmd, ) {
        $!process = Proc::Async.new(:w, |@cmd);
        # Tap into stdout asynchronously
        $!output = '';
        $!process.stdout.tap( -> $chunk {
            note (:$chunk) if $!echo;
            $!output ~= $chunk
        });
        # Start process
        $!promise = $!process.start;
        $!next-id = 0;
        return %(:$!process, :$!promise, :$!next-id);
    }

    method to-mcp-json(%assoc) {
        return to-json(%assoc, :!pretty);
    }

    method read() {
        return from-json($!output);
    }

    method request(Str:D $method, %params = %()) {
        my $id = $!next-id;
        my %msg =
            jsonrpc => "2.0",
            :$id,
            :$method,
            :%params,
        ;
        note "MCP::request::msg:\n", to-json(%msg, :pretty) if $!echo;
        $!output = '';
        await $!process.say(self.to-mcp-json(%msg));
        #$!process.close-stdin;
        sleep($!sleep);
        my $res = self.read();
        note "MCP::request::res: ", $res.raku if $!echo;
        $!next-id += 1;
        return $res;
    }

    method notify(Str:D $method, Mu $params = {}) {
        $!process.say(
                self.to-mcp-json({
                    jsonrpc => "2.0",
                    method  => $method,
                    params  => $params,
                })
        )
    }

    method initialize() {
        if $!initialized {
            note 'Initialized already.' if $!echo;
            return False;
        }
        my $res = self.request("initialize", {
            protocolVersion => "2025-11-25",
            capabilities    => {},
            clientInfo      => {
                name    => "RakuThinMCPClient",
                version => "0.1",
            },
        });
        $!initialized = True;
        self.notify("notifications/initialized");
        return True;
    }

    method list-tools() {
        my $res = self.request("tools/list");
        return $res<result><tools>;
    }

    method call-tool(Str:D $name, Mu $arguments = {}, ) {
        my $res = self.request("tools/call", {
            :$name,
            :$arguments,
        });
        return $res<result>;
    }

    method param-cpec($schema) returns Map:D {
        my %props = $schema<properties> // %();
        my @required = $schema<required> // [];
        return %props.kv.map( -> $name, $spec {
            $name => {
                type => "string",
                description => $spec<description> // "",
                :named
            }
        }).Hash
    }

    method to-llm-tool(%tool) returns LLM::Tool {
        my $name = %tool<name>;
        my $description = %tool<description> // "";
        my %parameters = self.param-cpec(%tool<inputSchema>);
        my @required = %tool<inputSchema><requried> // [];
        my %info =
                :$name,
                :$description,
                :%parameters,
                :@required;
        my &func =  -> *@args, *%args {
            note "LLM::Tool::arguments: ", (:@args, :%args) if $!echo;
            to-json(self.call-tool(%info<name>, %args))
        };
        return LLM::Tool.new(%info, &func)
    }

    method kill() {
        $!process.close-stdin;
        $!process.kill;
    }
}