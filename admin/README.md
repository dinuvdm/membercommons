Always use a virtualenv to protect your OS.
We use one virtualenv for an http server on port 8887, and another for Claude Code CLL.

In your webroot, run a webserver within a virtual environment. On Macs:

	python3 -m venv env
	source env/bin/activate
	python -m http.server 8887

On Windows:

	python -m venv env
	env\Scripts\activate
	python -m http.server 8887


Next, fork [membercommons](https://github.com/localsite/membercommons/) and clone into your webroot.

### 🛡️ Run Claude Code CLL

Run [Claude Code CLL](https://www.anthropic.com/claude-code) inside [your webroot]/membercommons folder:

	python3 -m venv env
	source env/bin/activate

For Windows,

	python -m venv env
	.\env\Scripts\activate


In the membercommons folder, install [NodeJS 18+](https://nodejs.org/en/download), then install Claude Code CLI:

	npm install -g @anthropic-ai/claude-code

Start Claude Code CLI:

	npx @anthropic-ai/claude-code

Inside the claude cmd window, start your local Rust API server by running:

	nohup cargo run -- serve > server.log 2>&1 &

The above keeps the server running and also stores logs,
whereas `cargo run -- serve` doesn't remain running.

View the website locally at: [localhost:8887/membercommons](http://localhost:8887/membercommons/)

<!--
  # Check if server is running
  curl http://localhost:8081/api/health

  # Stop the background server
  lsof -ti:8081 | xargs kill -9

  # View server logs
  tail -f server.log
-->

### Google Gemini

	npm install -g @google/gemini-cli

<!--
# Conda option

	conda create -n gemini-env python=3.9
	conda activate gemini-env

# npm worked above, pip didn't for L.
    pip install -q -U google-genai
-->