java_version := 8
default_java_version := 8
docker_org := docker-upload.nerdheim.de/nerdheim
platforms := linux/amd64,linux/arm64
cache := cache
docker := docker
jmx_exporter_major := 0
jmx_exporter_minor := 19
jmx_exporter_patch := 0

version_tags := $(jmx_exporter_major) $(jmx_exporter_major).$(jmx_exporter_minor) $(jmx_exporter_major).$(jmx_exporter_minor).$(jmx_exporter_patch)

tags_always := $(foreach version_tag,$(version_tags),$(version_tag)-java-$(java_version)) java-$(java_version)
tags_default := $(tags_always) $(version_tags) latest

images_target := prometheus-jmx-exporter

images := $(addsuffix -java-$(java_version), $(images_target))

images_iid := $(addsuffix .iid, $(images))

images_push := $(addsuffix .push, $(images) $(base_image))

all: $(base_image_iid) $(images_iid)

push: $(images_push)

clean:
	$(RM) -r "$(cache)" && \
	$(RM) *.iid *.push

%.iid: Dockerfile
	$(docker) buildx build \
		--cache-from "type=local,src=$(cache)" \
		--cache-to "type=local,dest=$(cache)" \
		--build-arg java_version="$(java_version)" \
		--iidfile "$@" \
		--platform "$(platforms)" \
		--output type=image \
		--target "$(patsubst %-java-$(java_version).iid,%,$@)" \
		-f "$<" .

%.push: %.iid
ifeq ($(java_version),$(default_java_version))
	$(docker) buildx build \
		--cache-from "type=local,src=$(cache)" \
		--cache-to "type=local,dest=$(cache)" \
		--build-arg java_version="$(java_version)" \
		--platform "$(platforms)" \
		--target "$(subst -java-$(java_version).push,,$@)" \
		$(foreach tag,$(tags_default), --tag "$(docker_org)/$(subst -java-$(java_version).push,,$@):$(tag)") \
		--push . && \
	touch "$@"
else
	$(docker) buildx build \
		--cache-from "type=local,src=$(cache)" \
		--cache-to "type=local,dest=$(cache)" \
		--build-arg java_version="$(java_version)" \
		--platform "$(platforms)" \
		--target "$(subst -java-$(java_version).push,,$@)" \
		$(foreach tag,$(tags_always), --tag "$(docker_org)/$(subst -java-$(java_version).push,,$@):$(tag)") \
		--push . && \
	touch "$@"
endif

.PHONY: all push clean
