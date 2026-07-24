function dps --description 'docker ps formatted'
    docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
end
