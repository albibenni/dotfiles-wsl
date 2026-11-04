---
name: question-master
description: Create or revise Test Yourself documents containing three to five open questions from learning material. Use for `.question.md` files with numbered prompts and individually matched suggested answers; do not use for multiple-choice quizzes or fill-in-the-blank worksheets.
---

# Question Master

Create open-ended questions that require explanation, application, comparison, diagnosis, or prediction rather than superficial recall.

## Workflow

1. Read the source and identify its defining vocabulary, roles or components, structural relationships, learning objectives, trade-offs, failure modes, adjacent concepts, and likely misconceptions.
2. Write three to five distinct questions, never more than five. Structure the opening questions so that:
   - Question 1 elicits the topic's focal point: what it is, what problem or purpose defines it, and why it matters.
   - Question 2 elicits the relevant actors, roles, components, or other participants and how they relate to the topic.
   - Question 3 elicits the most important terms or keywords to remember and what they mean in this topic.
   Adapt these lenses to the source rather than inventing actors or terminology it does not contain. Use questions 4 and 5, when included, for application, comparison, diagnosis, prediction, trade-offs, failure modes, or likely misconceptions. Avoid duplicating the same fact in different wording.
3. Give every question one concise suggested answer. Include the reasoning or acceptance criteria needed to evaluate a differently worded learner response.
4. Save the result with a `.question.md` suffix and validate it against the contract below.
5. When a source note is available, add the distinct Question references described below without changing links created by `quiz-master`.

## Grounding and Coverage

Make every numbered question independently understandable. A question runner may display one prompt without the document heading, neighboring questions, or introductory prose.

- Do not rely on a shared scenario, source link, document position, or another question for facts needed to interpret a prompt.
- Avoid positional and cross-question references such as “the example,” “the scenario above,” “the previous design,” or “question 3.” Include the minimum necessary context directly in each affected question.
- State all facts needed to interpret an invented scenario. A source link provides attribution and further study; it does not replace necessary question context.
- Cover the topic's canonical intent, named roles or components, defining mechanism or relationship, applicability, consequences, and important distinctions when the source supports them.
- Prefer source-specific recall and reasoning over generic best-practice questions. Broader design principles are useful only when the question and answer explicitly connect them back to the topic.

## File Contract

Use one questions section followed by one suggested-answers section. Headings may independently use English or Italian and are case-insensitive:

- `## Questions` or `## Domande`
- `## Suggested Answers` or `## Risposte suggerite`

Number both sections consecutively from `1` through `N`. Each answer must have the same number as exactly one question. Do not use letters, skip numbers, duplicate numbers, or add unmatched entries.

```markdown
# Topic Title

## Questions

1. First open-ended question?

2. Second open-ended question?

## Suggested Answers

1. Suggested answer to the first question.

2. Suggested answer to the second question.
```

Questions and answers may contain paragraphs, inline code, fenced code blocks, and nested lists. Indent nested numbered lists so only the question or answer identifiers begin at the left margin.

When a related source note and vault structure are available, place the document under that note's `Exercises and Quiz` folder unless the user specifies another location.

## Cross-links

When editing both the source note and the generated question document is in scope:

1. Add exactly one distinct question-file reference to the source note:

   ```markdown
   - Questions: [[<filename>.question|<filename> Questions]]
   ```

2. Add one Obsidian Wikilink back to the source note from the question document:

   ```markdown
   Source: [[<source note filename>]]
   ```

3. Add a question-specific Test Yourself link to both files:

   ```markdown
   [Test Yourself — Questions](test-yourself://open?quiz=<URL-encoded vault-relative .question.md path>)
   ```

Derive the deep-link path from the question file's actual final location. URL-encode the complete vault-relative path, including `/`; never include an absolute filesystem path or vault name.

These links are independent of quiz links. Preserve every existing `Quiz` Wikilink and every Test Yourself link targeting a quiz file. Never reuse, replace, or rewrite a `quiz-master` entry. Before inserting anything, detect the exact question-file target and avoid adding duplicate Question references or question deep links.

## Quality Check

Before finishing, confirm that:

- there are three to five questions, never more than five;
- questions 1–3 respectively cover the topic's focal point, its relevant actors/roles/components, and its essential terms or keywords, adapted to what the source actually contains;
- the required sections occur once and in the required order;
- both sections use the exact consecutive sequence `1..N`;
- every suggested answer addresses its matching question;
- the source and question file reference each other when both are in scope;
- Question links coexist with, and do not modify, existing Quiz links;
- terminology and assumptions remain faithful to the source;
- every numbered question remains interpretable when shown by itself, without introductory prose or neighboring questions;
- the set primarily tests the topic's defining knowledge rather than generic reasoning that could apply to many topics;
- ambiguous source material is identified instead of silently inventing a rule.
