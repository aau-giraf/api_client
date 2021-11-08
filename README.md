# Weekplanner
This repository contains a dart package which the weekplanner-app uses for comunnicating with the backend.   part of the weekplanner-app, which communicates with uses the api-client-repository to communicate with the backend (web-api-repository). 

The repository uses the Flutter framework to maintain the dart package, and it is currently running on Flutter version 2.0.5. The language used in this repository is Dart, which is the language the Flutter framework uses.

# Branches
This repository uses the scaled trunkbased branching strategy, as explained here: [Github setup](https://github.com/aau-giraf/.github/blob/main/wiki/about/github.md). In this repository the "trunk" is named develop, and this is the branch that all developers should branch from when solving an issue. The naming convention for these branches are:

| Issue type | Name                   | Example     |
| :--------: | :--------------------- | :---------: |
| User Story | feature/\<issue-number\> | feature/697 |
| Task       | task/\<issue-number\>    | task/918    |
| Bug fix    | bug-fix/\<issue-number\> | bug-fix/299 |

Other than the branches being used for development and the trunk, there exists some release branches, where the newest release branch is running on the PROD-environment. The release branches can only be created by members of the release group in the organization, and they should adhere to the following naming convention:
- Naming is release-\<release-version\> fx release-1.0
- A hot-fix on a release will increment the number after the dot (.)
- A new release will increment the number before the dot (.)

## License

GNU GENERAL PUBLIC LICENSE V3

Copyright [2020] [Aalborg University]
