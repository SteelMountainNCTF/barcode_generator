#!/usr/bin/awk -f

BEGIN { FPAT = "([[:space:]]*[^[:space:]]+)"; OFS = ""; }

function ltrim(x) {
  return gensub(/^[[:space:]]+/, "", "g", x)
}

{
  if ($1 ~ /w2c_i[0-9]+/ && $2 ~ /=/) {
    for (var in v) {
      if (v[var] == "") continue;
      for(i=3; i<=NF; i++) {
        gsub(var, v[var], $i)
      }
    }

    if ($2 ~ /^[[:space:]]*=$/ && $3 ~ /(w2c_.[0-9]+|[0-9]+u);$/) {
      v[ltrim($1)] = gensub(";", "", "g", ltrim($3))
      print "  // v[" ltrim($1) "] = " v[ltrim($1)]
    } else {
      print "  // clear cache"
      delete v[ltrim($1)]
    }
  } else {
    # invalidate cache
    for (var in v)
      delete v[var]
  }

  print
}
