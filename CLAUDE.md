# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-file IT PMO Kanban board demo for a fictitious bank: everything lives in `index.html` (markup, `<style>`, `<script>`). There is no build, lint, or test tooling, and no package manager. To run it, open the file in a browser (double-click or a `file://` URL). Do not add a server, bundler, or npm.

## Hard constraints (from the original spec)

- Vanilla HTML/CSS/JS only: no frameworks, no CDN scripts, no web fonts, no image files (system font stack, inline SVG or Unicode for icons).
- No persistence of any kind: no localStorage, sessionStorage, IndexedDB or cookies. Refreshing must reset the board to the seeded demo data (the UI says so).
- The only external call is the FormSubmit AJAX endpoint (`FORMSUBMIT_ENDPOINT`, top of the script). The user's email address must appear only there.
- No `!important`; no `alert()`/`confirm()` (delete confirmation is an inline "Delete? Yes / No"); no real bank logo or trademarks (neutral "IT PMO" wordmark, blue palette).
- Task IDs use the format `UOB-ITPM-####` as the spec requires, but the email subject prefix is deliberately the neutral `[IT PMO]`.

## Architecture

All behaviour hangs off one `state` object (`tasks`, `filters`, plus UI sub-state `pendingDeleteId`, `openMoveId`, `draggingId`, and the `nextId` counter). The rule is: mutate `state`, then call `renderBoard()`. Card DOM is only written by `renderBoard()`/`renderCard()`, which rebuild the board via `innerHTML`, so every user-supplied string must go through `escapeHtml()`.

Because the board is re-rendered wholesale, event handling uses delegation on `#board` (click via `data-action` attributes; `dragstart`/`dragover`/`dragleave`/`drop`). Any new per-card control should be a `data-action` button handled in `wireBoard()`, and after a re-render focus must be restored explicitly (see `focusCard()`).

Add Task flow (`handleSubmit`): validate → optimistic `addTask()` → reset/close form and success toast → `notifyNewTask()` in try/catch/finally. A FormSubmit failure only produces a warning toast and must never affect the board.

Seed data dates are computed relative to today (`offsetDate`) so overdue cards always appear in the demo. Overdue = `status !== "Done"` and `dueDate` (ISO string) before `todayISO()`.
