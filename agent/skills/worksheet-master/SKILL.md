---
name: worksheet-master
description: Generates an interactive fill-in-the-blank worksheet (.worksheet.md) designed to help memorize complex architectures, sequences, or code snippets (like auth flows).
---

# Worksheet Master

This skill creates "Worksheets" (fill-in-the-blank drills) to verify step-by-step understanding of technical flows, architectures, and sequences.

## Workflow

1.  **Analyze Context**: Identify sequential flows, pipelines, code architectures, or step-by-step processes (e.g., OAuth/PKCE flows, CI/CD steps, state machine transitions) in the provided context (e.g., a source `.md` file).
2.  **Generate Worksheet**: Create a fill-in-the-blank markdown document where critical terms, variables, or steps are replaced with the `{{correct_answer}}` syntax.
3.  **Cross-Reference**: Ensure the generated worksheet links back to the original source file, and update the original source file to link to the new worksheet.
4.  **Test Yourself Links**: After the worksheet is created, automatically add `[Test Yourself](test-yourself://open?quiz=<URL-encoded vault-relative path>)` to both the generated worksheet and its source explanation note. Derive the path from the worksheet's actual final location; the link always opens that worksheet in the Test Yourself app, including when followed from the source note.
5.  **Persist**: Write the full document to a file named `<topic>.worksheet.md` in the target folder, and save the updates to the original source `.md` file.

## Strict Formatting Requirements

The generated `<topic>.worksheet.md` file MUST strictly adhere to the following format so it can be parsed correctly by the Test Yourself application frontend and Rust backend:

1. **Frontmatter**: The file MUST begin with YAML frontmatter containing `type: worksheet` and the `topic`.
2. **Blank Syntax**: Use double curly braces containing the exact correct answer to denote a blank space: `{{answer}}`. You can provide multiple valid answers (synonyms) by separating them with a pipe `|`, e.g., `{{answer1 | answer2}}`.
3. **No Whitespace Padding**: Do not pad the inside of the braces with spaces. Use `{{code_verifier}}`, not `{{ code verifier }}` (unless the answer itself requires spaces, e.g., `{{Authorization header}}`).
4. **Numbered Questions**: Use numbered lists (`1. `, `2. `) to group related steps or individual questions. This allows the frontend to parse and render them into distinct question cards.
5. **Context Clues**: Ensure the sentence surrounding the `{{blank}}` provides enough technical context for the user to deduce what goes there.
6. **Explanations**: Provide an explanation at the very end of each numbered question using the syntax `> [!info] Explanation:` or `> Explanation:` followed by the explanation on the same line or subsequent lines.
7. **Cross-Referencing**: Include an Obsidian Wikilink at the top of the worksheet pointing back to the original source `.md` file (e.g., `*Generated from: [[source_note]]*`). Additionally, you MUST update the original source `.md` file with an Obsidian Wikilink pointing to the newly generated `.worksheet.md`.

### Example Format:

```markdown
---
type: worksheet
topic: PKCE
---

# PKCE Authorization Code Flow

*Generated from: [[oauth_guide]]*

1. The client application creates a cryptographically random string called the {{code_verifier}}. The client then calculates the SHA-256 hash of this string, which is known as the {{code_challenge}}.

> [!info] Explanation: The code_verifier acts as a high-entropy secret, and its hash, the code_challenge, is sent to the authorization server to prevent authorization code interception attacks.

2. The client redirects the user to the authorization server, including the `code_challenge` and setting the `code_challenge_method` to {{S256}}.

> [!info] Explanation: S256 indicates that the SHA-256 hash function was used. Plain should generally not be used as it does not hash the verifier.

3. After the user logs in, the authorization server redirects back to the client with an {{authorization code}}. The client sends a POST request to the token endpoint exchanging the authorization code and providing the original {{code_verifier}} to prove its identity.

> [!info] Explanation: The authorization server compares the received code_verifier by hashing it and matching it against the code_challenge it stored earlier.
```

## Guidelines

- **Focus on the "Why" and "How"**: Blank out the "glue" words, security terms, or variable names that actually matter to understanding the flow. Do not blank out obvious conjunctions or filler words.
- **Answer Length**: Keep answers inside the `{{}}` relatively short (1 to 4 words). Do not blank out entire sentences, as this becomes too frustrating to guess exactly.
- **Multiple Blanks**: It is highly encouraged to have multiple blanks in a single sentence if they test related concepts.
- **Progressive Difficulty**: Start the worksheet with basic definitions or the start of a flow, and progressively test deeper implementation details or edge cases as the worksheet goes on.
- **Link Formatting**: Never use `file:///` URLs, absolute filesystem paths, or relative paths in generated or updated `.md` files. Always use Obsidian Wikilinks (e.g., `[[source_note]]` or `[[worksheet_note]]`). Both the reference at the top of the worksheet and the backlink added to the source `.md` file MUST use Obsidian Wikilinks.
- **Test Yourself Link**: The Test Yourself link is the sole exception to the Wikilink rule. Use `test-yourself://open?quiz=<URL-encoded vault-relative worksheet path>` as its Markdown destination. URL-encode the entire path (including `/`) and never use a vault name or an absolute filesystem path. Add the same generated-file link once to the worksheet and once to the source explanation note; avoid duplicates.
