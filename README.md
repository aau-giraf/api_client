# Api-client
This repository contains a dart package which the weekplanner-app uses for comunnicating with the backend.   part of the weekplanner-app, which communicates with uses the api-client-repository to communicate with the backend (web-api-repository). 

The repository uses the Flutter framework to maintain the dart package, and it is currently running on Flutter version 2.0.5. The language used in this repository is Dart, which is the language the Flutter framework uses.

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

Copyright [2020] [Aalborg University]
