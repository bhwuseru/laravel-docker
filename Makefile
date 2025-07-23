SHELL := /bin/bash
.PHONY: container-init container-remove

docker-setup-env:
	@sudo ansible-playbook -i localhost, -c local ansible/environment-setup.yml

container-build-up:
	@sudo ansible-playbook -i localhost, -c local ansible/docker-build-up.yml

container-init:
	@ansible-playbook -i localhost, -c local ansible/environment-setup.yml && \
	ansible-playbook -i localhost, -c local ansible/docker-build-up.yml

container-remove:
	@sudo ansible-playbook -i localhost, -c local ansible/docker-container-reset.yml