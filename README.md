# Api-client
This repository hosts a Dart package that serves as a communication bridge between the weekplanner app and the backend system. The weekplanner app relies on this package to interact with the backend, and, in turn, this package connects to the web API repository for backend communication.

To develop and maintain this package, we utilize the Flutter framework. The current version of Flutter being used is 3.13.7. The primary programming language for this repository is Dart.

# Branches
This repository contains to main branches, develop and release, where develop is the branch that all developers should branch from when solving an issue, and release contains the code for the latest release of the api-client package. The weekplanners develop branch is running against the develop-branch whereas all of the release branches on the weekplanner are running against the release-branch. 

When a developer is working on an issue, they should create a new branch from develop, where the naming convention for these branches are:

| Issue type | Name                   | Example     |
| :--------: | :--------------------- | :---------: |
| User Story | feature/\<issue-number\> | feature/697 |
| Task       | task/\<issue-number\>    | task/918    |
| Bug fix    | bug-fix/\<issue-number\> | bug-fix/299 |

In order to make a new release of the api-client, one should go on the release branch and then pull the newest changes from the develop-branch. 

## License
GNU GENERAL PUBLIC LICENSE V3

Copyright [2023] [Aalborg University]
