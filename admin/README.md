Always use a virtualenv to protect your OS.
Here's we'll use one virtualenv for an http server, and another for Claude Code CLL.

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


View the website locally at: [localhost:8887/membercommons](http://localhost:8887/membercommons/)