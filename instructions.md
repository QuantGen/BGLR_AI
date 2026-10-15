# BGLR RAG Knowledge Base: Chunking Guidelines
## 1. Objective

The goal is to build a Retrieval-Augmented Generation (RAG) LLM that helps non-technical users write and understand using the BGLR library.

We are refactoring programs from https://github.com/gdlc/BGLR-R/ into https://github.com/QuantGen/BGLR_AI, organizing them into Markdown files with logically separated code chunks.

Each chunk should represent a specific coding task or functionality so that the chatbot can retrieve the relevant code based on a user's question.

## 2. Markdown File Structure

Each Markdown file should contain:

- Introduction: An overview of the topic, its purpose, prerequisites, and expected outcome.
- Code chunks: Relevant explanations and code, separated by logical functionality.
- Skills (optional): Additional technical knowledge the AI may need to answer questions or generate code.
Introduction

Every Markdown file must have an introduction enclosed within the following markers:
```
<!--intro starts -->

# Page Title

Describe the purpose of the page, the functionality covered,
any prerequisites, and the expected outcome.

<!--intro ends -->
```


The introduction should describe the overall topic, not just an individual code block.


## 3. Code Chunk Metadata

Every code group must have a metadata block immediately before its chunk-start marker.

Use this format:
```
<!--kb
agent: coding
package: BGLR
prompt: Fit a Bayesian Ridge Regression model using BGLR.
prompt: Run BRR using a genomic relationship matrix.
-->
<!--chunk starts -->

Insert the explanation and relevant code here.

<!--chunk ends -->

agent: Keep the value as coding.
package: Keep the value as BGLR.
prompt: Describe what the code does using natural language that reflects questions users might ask.
Writing prompts
```

A chunk can have multiple prompts if users may ask about the same functionality in different ways.

For example:

How do I fit a BRR model using BGLR?
How can I run BRR with a genomic relationship matrix?
How do I estimate genomic breeding values using BRR?

Each prompt must accurately describe the functionality implemented in the corresponding code chunk. Avoid redundant prompts or prompts describing functionality that the code does not support.

## 4. Chunk Boundaries

Enclose every code group within:

Start: <!--chunk starts -->
End: <!--chunk ends -->

Each chunk should represent one logical coding task, such as:

Preparing input data.
Constructing a genomic relationship matrix.
Configuring and fitting a BGLR model.
Extracting predictions or model results.
Evaluating model performance.

Keep related code together when it is required to understand or execute the task. Avoid splitting code into tiny, disconnected pieces.

Each chunk should include enough context to be useful when retrieved independently, including relevant explanations, required inputs, dependencies, code, and expected outputs.

## 5. Optional Skills Section

Use the following markers when additional knowledge may help the chatbot answer questions or generate correct code:
```
<!--skill starts -->

### Skills Required

- R programming fundamentals
- BGLR model specification
- Bayesian regression concepts
- Genomic prediction and relationship matrices

<!--skill ends -->
```

Include only skills relevant to the page. This section is optional.

## 6. Markdown Template

Use this template for new or refactored files:
```
<!--intro starts -->

# [Page Title]

Describe the purpose of the page, its scope, prerequisites,
and the expected outcome.

<!--intro ends -->

## [Code Group Title]

<!--kb
agent: coding
package: BGLR
prompt: [Describe what the code does.]
prompt: [Add another relevant user question, if needed.]
-->
<!--chunk starts -->

### Purpose

Explain what the code does and when it should be used.

### Inputs and Assumptions

Describe required inputs and dependencies.

### Code

    Insert the relevant, validated code here.

### Output

Explain the expected results.

<!--chunk ends -->

<!--skill starts -->

### Skills Required

- [Relevant programming knowledge]
- [Relevant BGLR or domain knowledge]

<!--skill ends -->

```
Repeat the code chunk section as many times as needed. Include the skills section only when useful.

