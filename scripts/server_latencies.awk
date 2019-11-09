BEGIN {
    thresholds[0] = -1;
    thresholds[1] = -1;
    thresholds[2] = -1;
}
{
    rtt = int($3 * 1000); # work in ms
    s = servers[$1 "/" $2];

    # awk has no arrays so these are comma separated lists
    if (s == ""){
        s = rtt;
    }else{
        s = s "," rtt;
    }
    servers[$1 "/" $2] = s;
}
END {
    for (s in servers){
        server = split(servers[s], server, ",");
        count = 0;
        sum = 0;
        for (i in server){
            sum = sum + server[i];
            count = count + 1;
        }

        # score with mean
        score = sum / count;

        # if we have enough samples for a 90th percentile, use that instead
        if(count > 20) {
            idx = int((0.9 * count) - 1);
            pctile = server[idx]; # 90th percentile
            score = percentile;
        }

        # this is just a brute force way to store the 3 best scores
        t = score;
        scores[s] = t;
        for(i in thresholds){
            if(t < thresholds[i] || thresholds[i] < 0){
                old = thresholds[i]
                thresholds[i] = t;
                t = old;
            }
        }
    }

    for (s in scores) {
        rtt = scores[s];
        weight = 0; # don't send traffic

        if(rtt <= thresholds[1]){
            weight = 1; # use second best score as backup
        }
        if(rtt <= thresholds[0]){
            weight = 256; # use best score for favorite
        }
        if(weights[s] != weight){
            # send new weight to haproxy
            print "set server " s " weight " int(weight);
        }
    }
}