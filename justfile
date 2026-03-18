name := "ubase"

# build docker image
build:
    docker build --rm -t {{name}} .

# run container (remove existing first)
run *args:
    docker rm -f {{name}} 2>/dev/null || true
    docker run -tid -v $PWD/work:/work --hostname {{name}} --name {{name}} {{name}}
    @if [ -n "{{args}}" ]; then docker exec -ti {{name}} {{args}}; fi

# exec into running container
exec cmd="bash":
    docker exec -ti {{name}} {{cmd}}

# remove container
rm:
    docker rm -f {{name}}

# save image as gzipped tar
pack:
    docker save {{name}} | gzip > {{name}}.gz
