#!/bin/bash
docker run --rm --privileged --interactive --tty \
                                  --security-opt seccomp=unconfined \
				  --volume "$(pwd):/src" \
                                  --workdir "/src" \
                                  swiftarm/swift
