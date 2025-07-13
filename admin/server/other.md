## ⚙️ Manual Server Start Instructions

### Step 1: Check if server is running
```bash
curl http://localhost:8081/api/health
```

### Step 2: Stop existing server (if needed)
```bash
lsof -ti:8081 | xargs kill -9
```

### Step 3: Start the server
```bash
cargo run serve
```

### Step 4: Verify it's running
```bash
curl http://localhost:8081/api/health
```

---

## Run Google Gemini CLI

	npm install -g @google/gemini-cli

<!--
# npm worked above, pip didn't for L.
    pip install -q -U google-genai
-->

### Conda option for running Google Gemini CLI

	conda create -n gemini-env python=3.9
	conda activate gemini-env

