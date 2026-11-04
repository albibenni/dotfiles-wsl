---
name: code-worksheet-master
description: Generates an interactive fill-in-the-blank worksheet (.worksheet.md) designed for code exercises, such as writing SQL queries or small snippets of code on a specific aspect.
---

# Code Worksheet Master

This skill creates "Code Worksheets" (fill-in-the-blank drills) to verify understanding of specific coding syntax, like SQL queries, JavaScript functions, or API usage.

## Workflow

1.  **Analyze Context**: Identify the coding topic requested by the user (e.g., SQL JOINs, React useEffect, Rust Option matching) from a source `.md` file.
2.  **Generate Worksheet**: Create a fill-in-the-blank markdown document where critical parts of code snippets or queries are replaced with the `{{correct_answer}}` syntax.
3.  **Cross-Reference**: Ensure the generated worksheet links back to the original source file, and update the original source file to link to the new worksheet.
4.  **Test Yourself Links**: After the worksheet is created, automatically add `[Test Yourself](test-yourself://open?quiz=<URL-encoded vault-relative path>)` to both the generated worksheet and its source explanation note. Derive the path from the worksheet's actual final location; the link always opens that worksheet in the Test Yourself app, including when followed from the source note.
5.  **Persist**: Write the full document to a file named `<topic>.worksheet.md` in the target folder, and save the updates to the original source `.md` file.

## Strict Formatting Requirements

The generated `<topic>.worksheet.md` file MUST strictly adhere to the following format so it can be parsed correctly by the Test Yourself application frontend and Rust backend:

1. **Frontmatter**: The file MUST begin with YAML frontmatter containing `type: worksheet` and the `topic`.
2. **Blank Syntax**: Use double curly braces containing the exact correct answer to denote a blank space: `{{answer}}`. You can provide multiple valid answers (synonyms) by separating them with a pipe `|`, e.g., `{{answer1 | answer2}}`.
3. **No Whitespace Padding**: Do not pad the inside of the braces with spaces. Use `{{SELECT}}`, not `{{ SELECT }}`.
4. **Context Clues**: Ensure the prompt or comments surrounding the code block provide enough technical context for the user to deduce what goes in the blanks.
5. **Numbered Questions**: Group each exercise into numbered lists (`1. `, `2. `). This ensures the frontend parses and renders each question block separately into its own card.
6. **Code Blocks**: The main content of the worksheet should be markdown code blocks (e.g., ```sql or ```javascript), with the blanks inside them.
7. **Explanations**: You MUST provide an explanation at the very end of each numbered question using the syntax `> [!info] Explanation:` or `> Explanation:` followed by the explanation on the same line or subsequent lines.
8. **Cross-Referencing**: Include an Obsidian Wikilink at the top of the worksheet pointing back to the original source `.md` file (e.g., `*Generated from: [[source_note]]*`). Additionally, you MUST update the original source `.md` file with an Obsidian Wikilink pointing to the newly generated `.worksheet.md`.

### Example Format:

```markdown
---
type: worksheet
topic: SQL_Joins
---

# SQL Joins Practice

*Generated from: [[sql_joins_guide]]*

1. Retrieve all users and their corresponding orders. If a user doesn't have an order, still include the user in the result.

` ` `sql
SELECT users.name, orders.amount
FROM users
{{LEFT JOIN}} orders {{ON}} users.id = orders.user_id;
` ` `

> [!info] Explanation: A LEFT JOIN ensures all records from the 'users' table are returned, even if there are no matching records in the 'orders' table.

2. Find the total number of orders for each user.

` ` `sql
SELECT users.name, {{COUNT(orders.id)}}
FROM users
JOIN orders ON users.id = orders.user_id
{{GROUP BY}} users.name;
` ` `

> [!info] Explanation: COUNT() is an aggregate function used to count rows. GROUP BY groups the results by the non-aggregated column, in this case, the user's name.
```
*(Note: use standard triple backticks for code blocks, not padded ones as shown in the nested markdown example above).*

## Guidelines

- **Focus on Logic and Syntax**: Blank out the important keywords, operators, or variables that actually test the user's understanding of the concept.
- **Answer Length**: Keep answers inside the `{{}}` relatively short (1 to 4 words). Do not blank out entire lines of code unless it's a very simple and standard pattern, as this becomes too frustrating to guess exactly.
- **Multiple Blanks**: It is highly encouraged to have multiple blanks in a single snippet if they test related concepts (e.g., both `GROUP BY` and the aggregation function).
- **Progressive Difficulty**: Start the worksheet with basic syntax, and progressively test deeper implementation details or edge cases as the worksheet goes on.
- **Link Formatting**: Never use `file:///` URLs, absolute filesystem paths, or relative paths in generated or updated `.md` files. Always use Obsidian Wikilinks (e.g., `[[source_note]]` or `[[worksheet_note]]`). Both the reference at the top of the worksheet and the backlink added to the source `.md` file MUST use Obsidian Wikilinks.
- **Test Yourself Link**: The Test Yourself link is the sole exception to the Wikilink rule. Use `test-yourself://open?quiz=<URL-encoded vault-relative worksheet path>` as its Markdown destination. URL-encode the entire path (including `/`) and never use a vault name or an absolute filesystem path. Add the same generated-file link once to the worksheet and once to the source explanation note; avoid duplicates.
