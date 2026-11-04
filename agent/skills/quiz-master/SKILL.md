---
name: quiz-master
description: Generates a self-contained, adaptive-length multiple-choice quiz that checks understanding of concepts, logic, and important details from the current context. Use for self-assessment and knowledge reinforcement, especially when the quiz should be concise, difficult, saved as a Markdown note, and sized to the topic unless the user specifies a fixed count.
---

# Quiz Master

Create concise, high-discrimination quizzes. Make each item fast to scan while making the decision depend on genuine understanding.

## Workflow

1. **Analyze Context and Language**: Identify the concepts, causal relationships, trade-offs, failure modes, and independent key arguments worth retaining. Prefer important ideas over incidental details. When a source document is provided or referenced, infer its primary natural language from the document's substantive content and write the quiz, answers, explanations, and added source-note links in that language. An explicitly requested output language overrides the inferred language. If the source is genuinely multilingual with no clear primary language, ask the user which language to use.
2. **Choose Quiz Length**: If the user requests a fixed number of questions, use it exactly and do not make a separate recommendation. Otherwise, recommend and use a count from 4 to 16 after assessing topic scope, conceptual complexity, and the number of independent key arguments:
    - **4–5**: A narrow topic with one or two tightly connected ideas.
    - **6–7**: A focused topic with several important concepts or one moderate workflow.
    - **8–10**: A standard note covering multiple concepts, relationships, or trade-offs.
    - **11–13**: A broad or technically complex topic with several independent arguments, workflows, or failure modes.
    - **14–16**: A comprehensive, highly interconnected topic where fewer questions would leave central arguments untested.
    Count distinct learn-worthy ideas rather than headings or document length. Increase within a band for dependencies, exceptions, trade-offs, and failure modes; do not add questions merely to cover minor details. State the recommendation and one brief reason before presenting the quiz.
3. **Generate Questions**: Cover foundational, intermediate, and advanced understanding in proportion to the selected count. For 4–5 questions, include at least 2 foundational and 1 intermediate item; for 6–9, aim for roughly 3 foundational, 3 intermediate, and the remainder advanced; for 10–16, use roughly one-third foundational, two-fifths intermediate, and the remainder advanced. Ensure every central independent argument is tested at least once without duplicating ideas.
4. **Make Every Item Standalone**: A learner must be able to answer from the question and its options without opening the source note. Restate the specific concept, scenario, behavior, code fragment, data, or claim needed for the decision. Never use unresolved references such as "the example," "the code above," "the note," "the source," "this approach," or "as discussed". Mentioning a named concept from the source is acceptable when the question itself supplies everything needed to distinguish the choices.
5. **Write Compact Items**: State the decision point first. Aim for one sentence per question; use a second short sentence only when it supplies essential scenario context. Keep the entire prompt on the numbered question line and each option on one line so Test Yourself renders it correctly. Keep options parallel in structure and closely matched in length. Before finalizing each item, compare the correct option with every distractor and shorten or expand wording until correctness cannot be inferred from length.
6. **Present and Persist Quiz**: Display options A through D and write the full quiz to `<topic>_quiz.md` in the target folder. Link the generated quiz and its source note using Obsidian Wikilinks. Add an exercise-file link only when such a file exists and is relevant.
7. **Add Test Yourself Links**: Add one `[Test Yourself](test-yourself://open?quiz=<URL-encoded vault-relative path>)` link to both the quiz and its source note. Derive the path from the quiz's actual final location.
8. **Evaluate with Detailed Solutions**: At the bottom of the file, add `## Answers`. For every answer, state the question number and correct letter (for example, `1. B`), followed immediately by a line starting exactly with `Explanation: `.
9. **Run a Standalone Review**: Read only the generated quiz, pretending the source note is unavailable. Rewrite any question whose referent, assumptions, or required evidence exists only in the note. Keep source links as navigation metadata; no question may depend on following them.

## Strict Formatting Requirements

The generated `<topic>_quiz.md` file MUST strictly adhere to the following format so it can be parsed correctly by external tools:

1. **Questions**: Each question must start with its number followed by a period (e.g., `1. What is...?`).
2. **Options**: The question must be immediately followed by options starting with `A. `, `B. `, `C. `, `D. ` (at least A and B are required).
3. **Answers Section**: Must be under a heading containing the word `Answers` or `Solutions`.
4. **Answer Key & Explanation**: Each correct answer must be stated as `1. B` (number, period, letter) and the very next line MUST begin exactly with the keyword `Explanation: `.

Example format:

1. What is the most effective way to prevent SQL Injection?
   A. Using a Web Application Firewall
   B. Using Prepared Statements
   C. Escaping all user input manually
   D. Obfuscating the database schema

## Answers

1. B
   Explanation: Prepared statements ensure that the database treats user input as data, neutralizing SQL injection attacks.

## Guidelines

- **Fast to Read**: Lead with the question, not a long setup. Use concrete verbs and familiar terms. Remove background the learner does not need to choose an answer. Never use a paragraph-length question or multi-line option.
- **Self-Contained Questions**: Source material may determine what to test, but it must not be required at quiz time. Replace references such as "Why does the example do this?" with the relevant fact, for example: "A temperature publisher emits an immutable event containing the triggering value. Why include that value?" If the answer depends on a snippet, formula, sequence, quotation, table value, or special definition, reproduce the minimal necessary material in the question itself; otherwise test the underlying concept without referring to the source artifact.
- **Hard for the Right Reason**: Make difficulty come from a consequential distinction: a boundary condition, causal direction, trade-off, order of operations, failure mode, or near-miss misconception. Do not make wording dense or intentionally ambiguous.
- **Plausible, Length-Balanced Distractors**: Base wrong options on realistic misconceptions or almost-correct alternatives. Keep all four options parallel in grammar, detail, and approximate length. The correct option must never be the uniquely longest or most detailed choice; if it needs a qualifier, give comparable qualifiers to the distractors or rewrite all options more compactly. Do not signal the answer through precision, certainty, or a visibly fuller explanation. Randomly vary correct letters across A–D; avoid predictable sequences.
- **Apply Understanding**: Prefer compact application questions over definition recall. Use a minimal scenario only when it changes the answer. Test recall only for terminology or facts that are foundational to the topic.
- **Important Coverage**: Prioritize core concepts, relationships, invariants, trade-offs, and common failure modes. Avoid trivia, duplicated ideas, and source-code details unless the relevant snippet appears in the question.
- **High-Signal Explanations**: When providing answers, explain _why_ the correct choice is right and _why_ others might be misleading. Provide detailed solutions that cover the underlying logic and context.
- **Contextual Accuracy**: Ensure all questions are grounded in the provided context, avoiding generic external knowledge unless relevant.
- **Language Consistency**: Match the inferred primary language of the referenced source document throughout the generated quiz and any text added to that source document, unless the user explicitly requests a different language.
- **Persistence**: Save the quiz and solutions as `<topic>_quiz.md` (for example, `bash_quiz.md`) in the target folder.
- **Link Formatting**: Never use `file:///` URLs, absolute filesystem paths, or relative paths in generated or updated `.md` files. Always use Obsidian Wikilinks (e.g., `[[topic_quiz]]` or `[[topic_quiz|Display Label]]`). Both the reference inside the generated `<topic>_quiz.md` file and the reference added to the original source `.md` file MUST use Obsidian Wikilinks.
- **Test Yourself Link**: The Test Yourself link is the sole exception to the Wikilink rule. Use `test-yourself://open?quiz=<URL-encoded vault-relative quiz path>` as its Markdown destination. URL-encode the entire path (including `/`) and never use a vault name or an absolute filesystem path. For example: `[Test Yourself](test-yourself://open?quiz=Computer%20Science%2FLanguages%2FJava%2FAdvanced%2FExercises%20and%20Quiz%2FReactive%20Programming_quiz.md)`. Add one link per file and avoid duplicates.
