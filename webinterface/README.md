# F5 CTF Lab Setup Guide

## Introduction
The F5 Capture the Flag (CTF) is an interactive and fun way to teach API concepts and security concerns. It’s designed for all experience levels, from beginners to advanced developers. Attendees will learn:
- What APIs are.
- How APIs function.
- How to identify and exploit API vulnerabilities.

Reassure participants that this is not a high-pressure hackathon. Everyone will gain value, whether they’re new to APIs or seasoned developers.

---

## What You Need to Play
- **Emphasize Fun**: This is a game, so participants should focus on enjoying and learning.
- **Tools Required**: A browser with developer tools is enough for most tasks. Advanced tools are optional.
- **Jumphost Option**: Provide a secure hosted environment for participants concerned about corporate policies. However, their own devices are sufficient.
- **Resources Provided**: All necessary tools are explained during the session.

---

## Setup Overview
The CTF requires centralized servers for scoring and challenges. To ensure fairness and security:
1. **CTF Server**: Hosts challenges and tracks scores.
2. **Student Jumphosts**: Isolated environments for participants to perform their tasks.

Centralizing the servers prevents students from directly accessing sensitive resources.

---

## Configuration Steps

### 1. Deploy the Server Blueprint
- Deploy the **Server Blueprint** to set up the CTF server.  The [Server blueprint](https://udf.f5.com/b/3e69d283-0b47-497b-9250-e95359bbdebc#documentation) is available here.
- Use the **Student Blueprint** to provide jumphosts for participants.  The [Student Blueprint](https://udf.f5.com/b/c8224624-6073-4e6c-b61b-824780e4b6e0#documentation) is available here.

---

### 2. Generate Public Links for CTF Servers
Use the UDF platform to share secure links:
- Expose Virtual Servers for **CTFd** (scoring) and **AppY** (challenge API).
- These links allow students to access the resources without direct deployment access.

---

### 3. Configure DNS in F5 XC
1. **Gather Required Information**:
   - **Tenant ID**: Found in **Administration > Tenant Settings > Tenant Overview**.
   [Administration](static/ctf-instructions-_12.png)
   [Administration Menu](static/ctf-instructions-_11.png)
   [Tenant Information](static/ctf-instructions-_14.png)
   - **Company Name**: Found in the same section as the Tenant ID.
   - **Namespace**: Found in **Administration > Personal Management > Namespaces** (usually based on your initials and last name).
   [Namespace Details](static/ctf-instructions-_1.png)
   - **API Token**: 
     - Create a token in **Administration > Personal Management > Credentials**.
     - Use a descriptive name (e.g., `mycoolctf-token`).
     - Set a short expiry date (e.g., a few days after the event).
     - **Important**: Copy the token when displayed. It won’t be shown again.
     [Administration User Management Credentials](static/ctf-instructions-_10.png)
     [Administration User Management Credentials](static/ctf-instructions-_9.png)
     [Administration User Management Credentials](static/ctf-instructions-_8.png)
     [Administration User Management Credentials](static/ctf-instructions-_7.png)
     [Administration User Management Credentials](static/ctf-instructions-_6.png)
     [Administration User Management Credentials](static/ctf-instructions-_5.png)
   - **Domain**: Your XC domain name. Found in **DNS Management > Manage > Delegated Domain Management**.
   [DNS Management delegated domain management](static/ctf-instructions-_3.png)

2. **Choose a Friendly URL Prefix**:
   - Example: `mycoolctf`.
   - Ensure it’s unique and avoids using customer names.

---

### 4. Prepare the Environment
1. Open the **CTF Management** link in the **CTF Server Deployment** (under the "containers" server).
2. Enter the gathered details:
   - Tenant ID
   - Domain
   - Company Name
   - Namespace
   - API Token
   - Friendly URL prefix

3. The system will:
   - Execute necessary `curl` commands.
   - Create Load Balancers and Pools in XC.

---

## Maintenance and Cleanup
- If the server deployment stops, the origin server URLs will change.
- Use the **Cleanup** option in the CTF Manager to reset the environment.
- Re-run the **Prepare Environment** script to restore functionality.

---

## Optional: Manual Configuration
Refer to the [GitHub repository](https://github.com/pmscheffler/ctf-scripts) for details on manual configuration.

---

Now your F5 CTF is ready to go! Engage participants with this fun and educational experience.
