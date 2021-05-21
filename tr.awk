#!/usr/bin/awk -f

BEGIN { FPAT = "([[:space:]]*[^[:space:]]+)"; OFS = ""; }

function alen (a,     i) {
    for (i in a);
    return i;}

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

    var = ltrim($1)
    if ($2 ~ /^[[:space:]]*=$/ && $3 ~ /(w2c_.[0-9]+|[0-9]+u);$/) {
      v[var] = gensub(";", "", "g", ltrim($3))
      print "  // v[" var "] = " v[var]
    } else if ($2 ~ /^[[:space:]]*[+\-*/|&]=$/ && $3 ~ /(w2c_.[0-9]+|[0-9]+u);$/ && v[var] != "") {
      v[var] = v[var] " " gensub("&", "\\\\&", "g", gensub(/[[:space:]=]/, "", "g", $2)) " " gensub(";", "", "g", ltrim($3))
      print "  // v[" var "] = " v[var]
      gsub(/.=/, "=", $2)
      gsub(ltrim($3), v[var], $3)
    } else {
      print "  // clear " var
      delete v[var]
    }
  } else if ($1 ~ /^[[:space:]]*return$/ && $2 ~ /^[[:space:]]*w2c_.[0-9]+;$/) {
    for (var in v) {
      if (v[var] == "") continue;
      gsub(var, v[var], $2)
    }
  } else if (ltrim($0) != "FUNC_EPILOGUE;") {
    # invalidate cache
    if (alen(v) > 0) {
      print "  // clear cache"
      for (var in v)
        delete v[var]
    }
  }

  print
}
