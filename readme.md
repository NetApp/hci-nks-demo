# Hybrid MultiCloud Demo

## Continuous Integration (CI) is a development practice that requires developers to integrate code into a shared repository several times a day. Each check-in is then verified by an automated build, allowing teams to detect problems early.
### What we are going to see, continuous integration
1. Review code in an IDE
1. Start the dynamic service locally from the IDE to examine a users workflow.
1. Make a change or two and restart the local service
1. Commit the change to source control and push to github.com
1. Review Google Cloud Build has triggered and is building the new images.
1. Review the k8s directory
1. Update the dynamic_deployment.yaml with the correct TAG value from GCB
1. Deploy the services per the readme.md in the k8s directory
1. Review the service as it is hosted
1. Deploy to another cloud service

## Next steps, continuous deployment
## Continuous deployment is a strategy for software releases wherein any code commit that passes the automated testing phase is automatically released into the production environment, making changes that are visible to the software's users.

1. Coming soon
