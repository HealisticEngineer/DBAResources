# Deadlock Fix Suggestion Script

This script is designed to help identify and suggest fixes for deadlocks in a SQL Server database. It retrieves the most recent deadlock report from the system health extended events and sends it to an AI model for analysis and suggestions.

## Prerequisites

- PowerShell
- SQL Server with system health extended events enabled
- Ollama API for AI model analysis

## Usage

1. **Set Connection Parameters:**
   - `$server`: The name of your SQL Server instance.
   - `$database`: The name of your database (default is `master`).
   - `$ollama`: The address and port of your Ollama instance.
   - `$model`: The AI model to use for analysis (default is `qwen2.5-coder:14b`).

2. **Run the Script:**
   - Execute the `deadlock_fix_suggestion.ps1` script in PowerShell.

```powershell
# Example usage
.\deadlock_fix_suggestion.ps1
```