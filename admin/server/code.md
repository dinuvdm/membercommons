### 🛡️ Run Claude Code CLL

Right click the membercommons folder and start a virtual environment.

**Mac/Linux** 

	python3 -m venv env
	source env/bin/activate

**For Windows**

	python -m venv env
	.\env\Scripts\activate


**Start Claude**

Inside the same terminal, run the followin to start [Claude Code CLI](https://www.anthropic.com/claude-code)

**Skip this line** if you've already installed Claude Code CLI.  
In the membercommons folder, install [NodeJS 18+](https://nodejs.org/en/download), then install Claude Code CLI:

	npm install -g @anthropic-ai/claude-code

Start Claude Code CLI:

	npx @anthropic-ai/claude-code

Inside the claude cmd window, start your local Rust API server by running:
(Maybe you can simply type "Start server")

	nohup cargo run -- serve > server.log 2>&1 &

The above keeps the server running and also stores logs,
whereas `cargo run -- serve` doesn't remain running inside the CLI.

View the website locally at: [localhost:8887/membercommons](http://localhost:8887/membercommons/)

<!--
  # Check if server is running
  curl http://localhost:8081/api/health

  # Stop the background server
  lsof -ti:8081 | xargs kill -9

  # View server logs
  tail -f server.log
-->