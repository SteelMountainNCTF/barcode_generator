#!/usr/bin/awk -f

BEGIN { FPAT = "([[:space:]]*[^[:space:]]+)"; OFS = ""; }

function alen (a,     i) {
    for (i in a);
    return i;}

function ltrim(x) {
  return gensub(/^[[:space:]]+/, "", "g", x)
}

function vargensub(search, var, trg) {
  if (v[var] != "") {
    return gensub(search, gensub("([&>?])", "\\\\\\1", "g", v[var]), "g", trg)
  } else {
    return trg
  }
}

{
  if ($1 ~ /w2c_.[0-9]+/ && $2 ~ /=/) {
    for (var in v) {
      if (v[var] == "") continue;
      for(i=3; i<=NF; i++) {
        $i = vargensub(var, var, $i)
      }
    }

    var = ltrim($1)
    rest = ""
    for (i=3; i<=NF; i++) {
      rest = rest $i
    }
    if ($2 ~ /^[[:space:]]*=$/ && rest ~ /(w2c_.[0-9]+|[0-9]+u|i32_load.+);$/) {
      # we assume that calls to i32_load don't modify anything
      v[var] = gensub(";", "", "g", ltrim(rest))
    } else if ($2 ~ /^[[:space:]]*[+\-*/|&]=$/ && $3 ~ /(w2c_.[0-9]+|[0-9]+u);$/ && v[var] != "") {
      v[var] = v[var] " " gensub(/[[:space:]=]/, "", "g", $2) " " gensub(";", "", "g", ltrim($3))
      gsub(/.=/, "=", $2)
      $3 = vargensub(gensub(";", "", "g", ltrim($3)), var, $3)
    } else if (alen(v) > 0) {
      if ($0 ~ /=.+,.+=/) {
        # invalidate cache
        print "  // clear cache"
        for (var in v)
          delete v[var]
      } else {
        print "  // clear " var
        delete v[var]
      }
    }
  } else if ($1 ~ /^[[:space:]]*return$/ && $2 ~ /^[[:space:]]*w2c_.[0-9]+;$/) {
    for (var in v) {
      $2 = vargensub(var, var, $2)
    }
  } else if (ltrim($0) == "FUNC_EPILOGUE;") {
    # pass
  } else if ($0 ~ /i32_store.+;/) {
    # we assume that calls to i32_store don't modify anything except i32_load's
    for (var in v) {
      $0 = vargensub(var, var, $0)
    }
    # invalidate cache
    i = 0
    for (var in v) {
      if (v[var] ~ /i32_load/) {
        delete v[var]
        i++
      }
    }
    if (i > 0) {
      print "  // clear storage cache"
    }
  } else {
    # invalidate cache
    if (alen(v) > 0) {
      print "  // clear cache"
      for (var in v)
        delete v[var]
    }
  }

  print
}
