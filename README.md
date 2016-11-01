Repository set of rules.

---==GITFLOW==---
One should use gitflow.

What is this all about? In a few simple words:

We've got a set of branches 'master', 'develop'.

Master will be a production branch and develop will be the one where all the ongoing work takes place.

So, when we want to work on some feature/ticket we create a feature branch and do our stuff there. After we finished our work on that feature - we should finish our branch and merge changes.

When we want to release a version we should start a release branch, update version number there, do other auxiliary stuff and pre-release preparations, then finish that branch, merge and we should have common state of our project in all the branches (develop, master) after release.

How do we achieve this with SourceTree?

SourceTree has an option to initialize gitflow for repository. We should press "init gitflow" and see dialog window where we name our development branch (develop), master branch, release branch, prefixes for releases and tags and other stuff. Once we click "ok" we're good to go with gitflow. We're in the development branch by default and before starting work on some feature we should press gitflow-->start new feature-->name feature. After we finished our work: gitflow-->finish current and it will automatically delete branch and merge all the changes.
Working with releases is quite similar and use the same flow gitflow-->start new release-->do your work-->finish current.
If a customer finds a bug we may use "hotfix", but it's pretty the same.
---==GITFLOW End==---

---==Commits==---
How to write commits messages?

Not only a commit message must contain a short description of changes done in this commit but a short description of why any work had been done.
Every developer can see the difference between two commits but it's very important to know why it has been done.

Bad commit message example:
"changed DummyViewController"

Good commit message example:
"updated DummyViewController with dummy things to match another dummy thing"

or even better:

"fixed bug where app would crash when entering DummyViewController;
the reason of crash was incorrect handling of setup values;
refs #999"

Another idea is to add references to tickets one's working on. Popular management systems like unfuddle or redmine can monitor repositories and link commits to tickets, so a customer or a project manager/ teamleader  or a person who performs code review can just open a ticket and see all the work done for that ticket.


---==Commits End==---
