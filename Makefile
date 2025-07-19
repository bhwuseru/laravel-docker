SHELL := /bin/bash
.PHONY: container-init container-remove

docker-setup-env:
	@ansible-playbook -i localhost, -c local ansible/environment-setup.yml

container-build-up:
	@ansible-playbook -i localhost, -c local ansible/docker-build-up.yml

container-init:
	@ansible-playbook -i localhost, -c local ansible/environment-setup.yml && \
	ansible-playbook -i localhost, -c local ansible/docker-build-up.yml

container-remove:
	@ansible-playbook -i localhost, -c local ansible/docker-container-reset.yml