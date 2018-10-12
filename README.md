# CodePraise

Application that allows *instructors* and *students* to guage how well individual students have contributed to *team projects*.

## Overview

Codepraise will pull data from Github's API, as well as clone and analyze blame information.

It will then generate *reports* to show how proportionately individual students have contributed to specific aspects of their project: testing, interface, infrastructure, etc. We call this a *praise* assessment: students should feel proud to have contributed to key parts of their project.

We hope this tool will give instructors a fair sense of how well students have contributed, but also that it gives students a sense of how their contributions are perceived objectively. We do not want our reports to be the sole basis of asessing student performance on team projects. Instead, we intend our praise reports to be the beginning of a conversation between instructors and students, and between team members, on how their contributions are perceived by others. It is upto team members and instructors to find a common understanding of how much, and how well, each student has contributed.

## Short-term usability goals

- Pull data from Github API, clone repos
- Analyze blame data to generate praise reports
- Display folder level praise reports

## Long-term goals

- Perform static analysis of folders/files: e.g., flog, rubocop, reek for Ruby