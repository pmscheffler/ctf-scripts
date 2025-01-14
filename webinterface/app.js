const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const path = require('path');

const app = express();
const port = 3000;

// Middleware to parse form data
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files (e.g., logo)
app.use('/static', express.static(path.join(__dirname, 'static')));

// HTML form with styling
const formPage = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>F5 Parameter Input</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        header {
            background-color: #d52b1e;
            padding: 20px;
            width: 100%;
            text-align: center;
            color: white;
        }
        header img {
            height: 50px;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .form-group input {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            background-color: #d52b1e;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #b02119;
        }
    </style>
</head>
<body>
    <header>
        <img src="/static/f5-logo.svg" alt="F5 Logo">
    </header>
    <div class="container">
        <h1>Enter Parameters</h1>
        <form action="/submit" method="POST">
            <div class="form-group">
                <label for="authtoken">API Token from XC:</label>
                <input type="text" id="authtoken" name="authtoken" required>
            </div>
            <div class="form-group">
                <label for="tenant">The Tenant of the User in XC:</label>
                <input type="text" id="tenant" name="tenant" required>
            </div>
            <div class="form-group">
                <label for="namespace">The Namespace of the User in XC:</label>
                <input type="text" id="namespace" name="namespace" required>
            </div>
            <div class="form-group">
                <label for="friendlyname">Part of the Hostname (CTFd or AppY will be prepended):</label>
                <input type="text" id="friendlyname" name="friendlyname" required>
            </div>
            <div class="form-group">
                <label for="xcconsole">The Hostname of the User's Console:</label>
                <input type="text" id="xcconsole" name="xcconsole" required>
            </div>
           <button type="submit" formaction="/prepare-environment" formmethod="POST">Prepare Environment</button>
            <button type="submit" formaction="/cleanup-environment" formmethod="POST">Clean Up Environment</button>
        </form>
    </div>
</body>
</html>
`;

// Serve the form page
app.get('/', (req, res) => {
    res.send(formPage);
});

// Handle Prepare Environment
app.post('/prepare-environment', (req, res) => {
    const { authtoken, tenant, namespace, friendlyname, xcconsole } = req.body;
    const command = `./prepare-environment.sh --authtoken "${authtoken}" --tenant "${tenant}" --namespace "${namespace}" --friendlyname "${friendlyname}" --xcconsole "${xcconsole}"`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing prepare script: ${error.message}`);
            res.status(500).send(`Error executing prepare script: ${error.message}`);
            return;
        }

        if (stderr) {
            console.error(`Prepare script error output: ${stderr}`);
            res.status(500).send(`Prepare script error: ${stderr}`);
            return;
        }

        res.send(`<h1>Environment Prepared Successfully</h1><pre>${stdout}</pre>`);
    });
});

// Handle Clean Up Environment
app.post('/cleanup-environment', (req, res) => {
    const { authtoken, tenant, namespace, friendlyname, xcconsole } = req.body;
    const command = `./cleanup-environment.sh --authtoken "${authtoken}" --tenant "${tenant}" --namespace "${namespace}" --friendlyname "${friendlyname}" --xcconsole "${xcconsole}"`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing cleanup script: ${error.message}`);
            res.status(500).send(`Error executing cleanup script: ${error.message}`);
            return;
        }

        if (stderr) {
            console.error(`Cleanup script error output: ${stderr}`);
            res.status(500).send(`Cleanup script error: ${stderr}`);
            return;
        }

        res.send(`<h1>Environment Cleaned Up Successfully</h1><pre>${stdout}</pre>`);
    });
});

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
