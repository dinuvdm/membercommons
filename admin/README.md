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