BEGIN {
    min = -1;
    thresholds[0] = -1;
    thresholds[1] = -1;
    thresholds[2] = -1;
}
{
    # only include upstream servers with passing health checks and a check latency
    if($39 ~ /^[0-9]+$/ && $1 == "upstream" && ($37 == "L4OK" || $37 == "L6OK" || $37 == "PROCOK")) {
        rtt = $39;
        servers[$1 "/" $2] = rtt;
        weights[$1 "/" $2] = $19;
        status[$1 "/" $2] = $18
        if(min < 0 || rtt < min){
            min = rtt
        }
        
        #bucket = rtt * 1.5 # just use double rtt as a reasonable bucketing mechanism
        t = rtt
        for(i in thresholds){
            if(t < thresholds[i] || thresholds[i] < 0){
                old = thresholds[i]
                thresholds[i] = t;
                t = old
            }
        }
    }
}
END {
    max = thresholds[0]
    range = max - min
    if(range < 1){
        range = 256
    }
    for (s in servers) {
        weight = 0; # weight 0 should treat them as a backup
        if(servers[s] <= thresholds[1]){
            weight = 1
        }
        if(servers[s] < threshold[0] || (servers[s] <= thresholds[1] && thresholds[1] < (1.5 * thresholds[0]))){
            weight = int(256 - ((servers[s] - min) / (range)) * 256); # use best servers for real balancing
        }
        if(weights[s] != weight){
            # send new weight to haproxy
            print "set server " s " weight " weight;
        }
    }
}