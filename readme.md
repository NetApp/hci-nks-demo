# Hybrid MultiCloud CI/CD Demo

## Continuous Integration (CI) is a development practice that requires developers to integrate code into a shared repository several times a day. Each check-in is then verified by an automated build, allowing teams to detect problems early.

 
1. Development
    1. Very quick overview of source code
    1. Look at the Dockerfiles and start them running locally
    1. Make a change or two
    1. Restart the docker files and review the changes
1. Continuous integration
    1. Commit the changes to github.com
    1. Watch them built on google cloud platform
    1. Review the build logs
    1. Grab the docker build tag
1. Operations
    1. Paste the docker build tag into the kubernetes yaml files
    1. Re-deploy the app and verify changes
    1. Demo updating an environment var setting in yaml
    1. Demo edit the live environment via kubectl
    1. Deploy applying to another environment

## Continuous Deployment (CD) is a strategy for software releases wherein any code commit that passes the automated testing phase is automatically released into the production environment, making changes that are visible to the software's users.

1. Coming soon 
