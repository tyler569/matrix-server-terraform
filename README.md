# Matrix Server Terraform

This repo contains the configuration I've used to set up my self-hosted
Matrix server and connect it to the global federation.

This isn't reusable as-is because I've hardcoded my domain name in a few
places, but it should be pretty easy to untie if you're motivated. I
like the idea that I'll come back and make this more generic in the
future, but no promises.

So far I've manually configured the EC2 instance to run nginx and the
provided docker-compose file, but I hope to automate that in the future
with something like ansible.
