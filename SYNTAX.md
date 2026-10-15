# Obsessed Markdown Syntax

This file is the contract. The parser, the node graph, the web server and anyone editing in Obsidian all follow these rules. If the code and this file disagree, change one of them on purpose.

Everything here is plain markdown. A vault written for Obsessed still opens in Obsidian, VS Code or GitHub; those tools just don't run the wires.

> Draft v0.1, 2026-10-15. Parts marked **Proposed** need a final yes before they get built.

## 1. Tasks

A task is a list item with one character in square brackets:

```md
- [ ] Polish pass @ika ^a2
```

| Part | Meaning |
|---|---|
| `- ` | List marker. `-`, `*` and `+` all work. |
| `[ ]` | Status. Exactly one character between the brackets (a space counts). What it means comes from the file's status format (section 2). |
| `Polish pass` | Task text. Anything goes, including emoji and links. |
| `@ika` | Optional. A person on the task (section 3). |
| `^a2` | Optional. The task's ID (section 4). A task needs one before a wire can point at it. |

Rules:

- Tasks can be indented under other tasks (subtasks).
- Lines inside code fences (` ``` ` or `~~~`) are never tasks.
- The brackets must come right after the list marker and a space. `Text with [ ] in the middle` is not a task, and neither is `-[ ] no space`.
- Numbered lists (`1. [ ]`) are not supported in v0.1.

## 2. Status format

Each file can say which statuses it uses and how the app draws them:

```md
::statusformat:: [-] = ⚪ = cannot start, [ ] = 🔳 = ready to start, [?] = ❓ = ready to check, [x] = ✅ = Finished ::statusformat::
```

Each entry is `[character] = symbol = label`:

| Part | Example | Meaning |
|---|---|---|
| character | `[?]` | What you type in the task's brackets. |
| symbol | `❓` | What the app draws instead of the brackets. Usually an emoji, but any short text works. |
| label | `ready to check` | The name shown in menus and tooltips. Can't contain `,` or `=`. |

Writing it:

- Open and close with `::statusformat::`. The opening marker must start a line.
- Separate entries with commas, new lines, or both. Spaces around `=` and `,` don't matter, so `[?] =❓ = ready to check ,` is fine.
- It can span several lines:

  ```md
  ::statusformat::
  [-] = ⚪ = cannot start,
  [ ] = 🔳 = ready to start,
  [?] = ❓ = ready to check,
  [x] = ✅ = Finished
  ::statusformat::
  ```

- The order is the pipeline order (see clicking in section 6).
- A status format inside a code fence is ignored, the same as tasks.

Where it goes and how many:

- Put it anywhere in the file: at the top, after the title, or at the bottom.
- One format applies to the **whole file**. If a file has more than one, **the last one wins**. The parser reads top to bottom and each new one replaces the one before. The app warns about any it ignored.
- If a file has no format, it uses the built-in default, which is the example at the top of this section. Later, a vault-wide default can live in `.obsessed/` (section 7).

### Fixed meanings (Proposed)

Each file can rename its statuses and give them any emoji, but three characters always mean the same thing to the wire engine. That's what lets wires connect files that use different formats:

| Character | Meaning for wires | Required in a format? |
|---|---|---|
| `[ ]` | Open: can be worked on. | Yes |
| `[x]` | Done. The only status that satisfies `needs::` and fires `sync::`. `[X]` counts as `[x]`. | Yes |
| `[-]` | Blocked: something it needs isn't done. The app sets and clears this one for you (section 6). | No |

Every other character (`[?]`, `[/]`, `[r]`, and so on) is a custom in-between status. To the wire engine it just means "not done yet".

Why fix these three? File A might call `[x]` "Approved" and file B might call it "Delivered". A wire from A to B still works because both mean done. It also means GitHub and Obsidian show `[ ]` as unchecked and `[x]` as checked.

### Mistakes

- A task uses a character that isn't in the file's format: the app shows ⚠ and leaves the line alone.
- A format is missing `[ ]` or `[x]`: the app warns, and those two fall back to the default symbol and label.
- An entry is broken: it's skipped with a warning and the rest of the format still works.

## 3. People

`@name` on the task's first line assigns someone. Several people per task are fine.

- Names use letters, digits, `-` and `_`.
- The `@` has to start a word, so `bob@example.com` is not a mention.
- Where the crew list lives (role, skills, card portrait) gets decided in milestone 7.

## 4. Task IDs

```md
- [ ] Polish pass @ika ^a2
```

- `^id` goes at the very end of the task's first line, after a space.
- IDs use letters, digits and `-`. This is the same format as Obsidian's block IDs, so Obsidian links to them work too.
- Each ID must be unique within its file.
- You don't have to type them. When you draw a wire to a task that has no ID, the app adds a short random one (like `^k3f9`).
- The ID never changes when the task text changes or the line moves. That's why wires point at IDs and not at text or line numbers.

## 5. Links and wires

A link to a task is `[[path/to/file#^id]]`. The path starts at the vault root and leaves out `.md`. For a task in the same file, use `[[#^id]]`. This is Obsidian's block link format, so clicking the link in Obsidian jumps to the task.

> The mockups in `docs/mockups/` were made before this spec. Where they differ, this file wins.

Wires are fields on indented lines directly under a task:

```md
- [-] Render lighting pass @maya @unit7 ^l2
  needs:: [[anim/sh040#^a2]], [[fx/sh040-water#^f2]]
```

A wire is written on the task that **receives** it (the downstream task), the same way a Blueprint input pin holds its connection.

| Field | Kind of wire | What it does |
|---|---|---|
| `needs::` | State, like a pure data pin | This task stays blocked until every linked task is `[x]`. Recalculated whenever something changes. It never fires actions by itself. |
| `sync::` | Event, like an exec pin | When the linked task **becomes** `[x]`, set this task to `[x]` too. This one changes files. |

- Separate several links in one field with commas or spaces.
- A field can appear on more than one line; the links add up.

## 6. Behaviour (Proposed)

- **Unblocking (the studio flip):** when every `needs::` of a `[-]` task becomes `[x]`, the app rewrites it to `[ ]` (ready to start). The change is written to the file, so Obsidian, git and teammates see it too.
- **Retakes:** if a needed task stops being `[x]` and this task is still `[ ]`, the app sets it back to `[-]`. If this task has already moved on (a custom status or `[x]`), the app leaves it alone and shows a warning.
- **Files without `[-]`:** the app shows a lock icon on blocked tasks but doesn't write anything.
- **Opening doesn't edit:** opening a vault never changes files. If a task's saved status disagrees with its `needs::`, it gets a warning badge until something changes.
- **Clicking:** a click moves a task to the next status in its format's order and skips `[-]`. Clicking `[x]` does nothing, so an approved shot can't be un-approved by accident. Right-click opens a list of every status in the format. Statuses listed after `[x]` (like a retake) can only be reached that way.
- **Blocked tasks** can't be clicked while their `needs::` aren't met. A `[-]` task with no `needs::` was blocked by hand, so it can be changed normally.
- **Loop guard:** within one chain reaction, wires and operator nodes can change each task at most once. If the chain tries to change a task a second time, that change is skipped and the app reports the loop. The change that started the chain doesn't count, so a flow can still send a task straight back (for example ✅ → 🔁 retake when a Text Check fails).
- **Log and undo:** every change a wire or operator node makes is logged with the file, line, old value and new value. A whole chain reaction undoes as one step, newest chain first.
- **Outside edits:** when a file changes outside the app (Obsidian, VS Code, `git pull`), the app re-reads it. Status changes in it fire wires like any other change, so people using other tools don't break the pipeline. They show in the log as outside edits and can't be undone from the app.

## 7. The `.obsessed/` folder

This folder sits at the vault root and holds everything that isn't a task:

- `flows/<name>.json`: one file per flow (a saved graph). It lists which files appear in the flow, where each node sits, the operator nodes (Text Check, Find & Replace, Set Status, ...) and the exec wires between them.
- vault settings, like a vault-wide default status format

The files are JSON, and the exact format gets decided in milestone 6. You never need to edit them by hand.

## 8. How it looks in other tools

| Syntax | Obsidian | GitHub |
|---|---|---|
| `- [ ]` and `- [x]` | Checkbox | Checkbox |
| `- [-]`, `- [?]` and other characters | Checked box, unless a theme styles it | Plain text |
| `::statusformat:: ...` | Plain text | Plain text |
| `needs:: ...` | Text. The Dataview plugin reads it as a field. | Plain text |
| `[[file#^id]]` | Link that jumps to the task | Plain text |
| `^id` | Hidden in reading view | Plain text |

## 9. Full example

`lighting/sh040.md`:

```md
# Lighting – sh040

Late-afternoon sun, warm key from camera left.

## Tasks

- [x] Key and fill setup @maya @unit7 ^l1
- [-] Render lighting pass @maya @unit7 ^l2
  needs:: [[anim/sh040#^a2]], [[fx/sh040-water#^f2]]

::statusformat:: [-] = ⚪ = cannot start, [ ] = 🔳 = ready to start, [?] = ❓ = ready to check, [x] = ✅ = Finished ::statusformat::
```

When both linked tasks become `[x]`, `^l2` flips from ⚪ to 🔳 and the file now reads `- [ ] Render lighting pass ...`.

## Ideas for later (not in v0.1)

- Sections with their own status format, where a format applies from where it appears downward.
- Hiding the format block in Obsidian with an Obsidian comment (`%% ... %%`).
- Numbered task lists, due dates, priorities.
