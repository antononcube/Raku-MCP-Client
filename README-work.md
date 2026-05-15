# MCP::Client

This Raku package, "MCP::Client", implements a _thin_ [Model Context Protocol (MCP)](https://modelcontextprotocol.io/docs/getting-started/intro) client.

"MCP::Client" provides the class `MCP::Client` which creates from MCP server's methods `LLM::Tool` objects 
that can be used with Raku's Large Language Model (LLM) framework implemented with 
["LLM::Functions"](https://raku.land/zef:antononcube/LLM::Functions), ["LLM::Prompts"](https://raku.land/zef:antononcube/LLM::Prompts), ["Text::SubParsers"](https://raku.land/zef:antononcube/Text::SubParsers); see [AA1÷4, AAp1÷3].

---

## Installation

From Zef ecosystem:

```
zef install MCP::Client
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-MCP-Client.git
```

---

## Example

This section has a complete usage example.

The MCP server is created and run in Python -- see the file ["simple_mcp_server.py"](../resources/simple_mcp_server.py).
That MCP server provides the methods `add`, `random_words_list`, `random_pet_names_list`, and `random_pretentious_job_title_list`.
The corresponding Python packages have to be installed -- see the `from ... import ...` statements in that Python file.

**Remark:** The Raku file ["MCP-client-demo.raku"](https://github.com/antononcube/Raku-MCP-Client/blob/main/examples/MCP-client-demo.raku) has all the code below.

#### Packages

Load the packages used below:

```raku
use LLM::Functions;
use LLM::Prompts;
use Text::SubParsers;
use Data::Translators;

use MCP::Client;
```

### Setup and initialization

Setup MCP server process creation command elements:

```raku
my $python = $*HOME ~ '/miniforge3/bin/python';
my $mcp-server-file =  $*HOME ~ '/Python/MCP/simple_mcp_server.py';

die "Cannot find Python executable ⎡$python⎦." unless $python.IO.f;
die "Cannot find MCP server file ⎡$mcp-server-file⎦." unless $mcp-server-file.IO.f;

# say "Using the Python executable ⎡$python⎦.";
# say "Using the MCP server file ⎡$mcp-server-file⎦.";
```


Create the MCP client object:

```raku
my Bool:D $echo = False;
my Numeric:D $sleep = 0.7;
my $client = MCP::Client.new(:$echo, :$sleep);

sink $client.start([$python, '-i', $mcp-server-file]);
```

Initialize the client:

```raku
$client.initialize;
```


### Tools discovery and creation

Get the MCP server tools list (and tabulate parts of it):

```raku, results=asis
my @mcp-tools = |$client.list-tools();
@mcp-tools
andthen .&to-html(field-names => <name description>, align => 'left').subst("\n", '<br>', :g)
```

Make `LLM::Tool` objects:

```raku
my @tools = @mcp-tools.map({ $client.to-llm-tool($_) });
```


### LLM invocations

Using an LLM request generate a list of random words (via a MCP server provided tool):

```raku
my $conf = llm-configuration('ChatGPT', model => 'gpt-4.1-mini', :@tools);
say llm-synthesize('Generate a list of 12 random cat pet names.', e => $conf);
```


Generate a JSON object of random pretentious jobs, and deserialize and print it:

```raku, results=asis
my $res = llm-synthesize([
    'Generate a list of six random bullshit jobs, in English, and three in Bulgarian.)',
    llm-prompt('NothingElse')('JSON')
    ],
    e => $conf,
    form => sub-parser('JSON'):drop
);

$res
==> to-html(align => 'left')
```

### Stopping the MCP server process

Kill the MCP client process:

```raku
$client.kill;
```

----

## References


## Articles, blog posts

[AA1] Anton Antonov,
["LLM function calling workflows (Part 1, OpenAI)"](https://rakuforprediction.wordpress.com/2025/06/01/llm-function-calling-workflows-part-1-openai/),
(2025),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA2] Anton Antonov,
["LLM function calling workflows (Part 2, Google's Gemini)"](https://rakuforprediction.wordpress.com/2025/06/01/llm-function-calling-workflows-part-2-google-gemini/),
(2025),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA3] Anton Antonov,
["LLM function calling workflows (Part 3, Facilitation)"](https://rakuforprediction.wordpress.com/2025/06/08/llm-function-calling-workflows-part-3-facilitation/),
(2025),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AA4] Anton Antonov,
["LLM function calling workflows (Part 4, Universal specs)"](https://rakuforprediction.wordpress.com/2025/09/28/llm-function-calling-workflows-part-4-universal-specs/),
(2025),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

### Packages

[AAp1] Anton Antonov, [LLM::Functions, Raku package](https://github.com/antononcube/Raku-LLM-Functions), (2023-2026), [GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov, [LLM::Prompts, Raku package](https://github.com/antononcube/Raku-LLM-Prompts), (2023-2026), [GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov, [Text::SubParsers, Raku package](https://github.com/antononcube/Raku-Text-SubParsers), (2023), [GitHub/antononcube](https://github.com/antononcube).