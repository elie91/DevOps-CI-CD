# Use a existing docker image as a base
# the alpine images are smallest as possible
FROM alpine

# Download and install a dependency
# this step, create a temporary container with the image specified before (alpine) (runnig in <id> ..)
# execute the RUN command in the new container as a main process
# after that, the system take a snapshot of the current file system in the temporary container, and remove him
RUN apk add --update redis

# Command when the container start
# take the container from the instruction before
CMD ["redis-server"]

# each instruction (sauf la 1er, FROM) create an intermediate container, that contains the snapshot from the container before
# the temporary container is removed when the instruction is finished