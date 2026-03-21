# Skill Authoring Best Practices

Source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

## Contents

- Core principles (conciseness, degrees of freedom, testing)
- Skill structure (naming, descriptions, progressive disclosure)
- Workflows and feedback loops
- Content guidelines
- Common patterns (template, examples, conditional workflow)
- Anti-patterns
- Advanced: executable code
- Checklist for effective skills

## Core Principles

### Concise Is Key

The context window is a shared resource. At startup, only metadata (name, description) is pre-loaded. SKILL.md loads when relevant. Once loaded, every token competes with conversation history.

**Default assumption:** Claude is already very smart. Only add context Claude doesn't already have.

Good (50 tokens):
````markdown
## Extract PDF text
Use pdfplumber for text extraction:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

Bad (150 tokens): Explains what PDFs are and how libraries work.

### Degrees of Freedom

- **High freedom** (text instructions): Multiple approaches valid, decisions depend on context
- **Medium freedom** (pseudocode/scripts with parameters): Preferred pattern exists, some variation acceptable
- **Low freedom** (exact scripts): Operations are fragile, consistency critical, exact sequence required

Think of Claude as a robot: narrow bridge with cliffs = low freedom (exact commands). Open field = high freedom (general direction).

### Test With All Models

- Haiku: Does the Skill provide enough guidance?
- Sonnet: Is the Skill clear and efficient?
- Opus: Does the Skill avoid over-explaining?

## Skill Structure

### Naming Conventions

Use **gerund form** (verb + -ing): `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`.

Acceptable alternatives: noun phrases (`pdf-processing`), action-oriented (`process-pdfs`).

Avoid: vague names (`helper`, `utils`), overly generic (`documents`, `data`), reserved words.

### Writing Effective Descriptions

**Always write in third person.** The description is injected into the system prompt.

- Good: "Processes Excel files and generates reports"
- Avoid: "I can help you process Excel files"
- Avoid: "You can use this to process Excel files"

**Be specific and include key terms.** Include both what and when.

Good examples:
- "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
- "Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes."

### Progressive Disclosure

SKILL.md serves as an overview pointing to detailed materials. Keep under 500 lines.

**Pattern 1: High-level guide with references**
```markdown
## Quick start
[Essential content]

## Advanced features
**Form filling**: See [FORMS.md](FORMS.md)
**API reference**: See [REFERENCE.md](REFERENCE.md)
```

**Pattern 2: Domain-specific organization**
```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md
    ├── sales.md
    └── product.md
```

**Pattern 3: Conditional details**
```markdown
## Basic usage
[inline content]

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

### Avoid Deeply Nested References

Keep references one level deep from SKILL.md. Claude may only preview deeply nested files.

### Structure Longer Files With TOC

For reference files over 100 lines, include a table of contents at the top.

## Workflows and Feedback Loops

### Use Workflows for Complex Tasks

Provide a checklist that Claude can copy and track:

```
Task Progress:
- [ ] Step 1: Analyze the form
- [ ] Step 2: Create field mapping
- [ ] Step 3: Validate mapping
- [ ] Step 4: Fill the form
- [ ] Step 5: Verify output
```

### Implement Feedback Loops

Common pattern: Run validator -> fix errors -> repeat.

```markdown
1. Make your edits
2. **Validate immediately**: run validation
3. If validation fails: fix issues, run validation again
4. **Only proceed when validation passes**
```

## Content Guidelines

### Avoid Time-Sensitive Information

Bad: "If you're doing this before August 2025, use the old API."

Good: Use an "Old patterns" section with `<details>` for deprecated approaches.

### Use Consistent Terminology

Choose one term and use it throughout. Don't mix "API endpoint", "URL", "API route", "path".

## Common Patterns

### Template Pattern

For strict requirements: "ALWAYS use this exact template structure"
For flexible guidance: "Here is a sensible default format, but use your best judgment"

### Examples Pattern

Provide input/output pairs for style-sensitive output (commit messages, PR descriptions, etc.).

### Conditional Workflow Pattern

Guide Claude through decision points:
```markdown
1. Determine the type:
   **Creating?** → Follow "Creation workflow"
   **Editing?** → Follow "Editing workflow"
```

## Anti-Patterns

- **Windows-style paths**: Always use forward slashes
- **Too many options**: Provide a default with escape hatch, don't list 5 alternatives
- **Assuming tools installed**: Be explicit about dependencies

## Advanced: Executable Code

### Solve, Don't Punt

Handle errors in scripts rather than failing and letting Claude figure it out. Document all constants (no "voodoo constants").

### Provide Utility Scripts

Pre-made scripts are more reliable, save tokens, save time, and ensure consistency. Make clear whether Claude should execute or read the script.

### Create Verifiable Intermediate Outputs

Plan-validate-execute pattern: create a plan file -> validate with script -> execute. Catches errors early.

### MCP Tool References

Always use fully qualified names: `ServerName:tool_name`.

## Checklist for Effective Skills

### Core Quality
- [ ] Description is specific with key terms
- [ ] Description includes what AND when
- [ ] SKILL.md body under 500 lines
- [ ] Additional details in separate files
- [ ] No time-sensitive information
- [ ] Consistent terminology
- [ ] Concrete examples
- [ ] File references one level deep
- [ ] Progressive disclosure used
- [ ] Workflows have clear steps

### Code and Scripts
- [ ] Scripts solve problems (don't punt to Claude)
- [ ] Explicit error handling
- [ ] No magic constants
- [ ] Required packages listed
- [ ] No Windows-style paths
- [ ] Validation steps for critical operations
- [ ] Feedback loops for quality-critical tasks

### Testing
- [ ] At least three evaluations created
- [ ] Tested with target models
- [ ] Tested with real usage scenarios
