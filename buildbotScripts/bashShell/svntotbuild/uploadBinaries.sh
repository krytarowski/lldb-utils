#!/usr/bin/env bash
set -e -x
source setEnv.sh

rev=$(svnversion $llvmDir)
cd $rootDir
zip -r rev-$rev build/android-*/bin
gsutil cp rev-$rev.zip $gsbinaries/
rm rev-$rev.zip

{
    printf '{ '
    for i in arm aarch64 i386 x86_64 mips mips64; do
        printf '"%s_server_size": %d, ' "$i" "$(wc -c <"$rootDir/build/android-$i/bin/lldb-server")"
    done
    printf '"revision": %d }\n' "$rev"
} >"rev-$rev.bq"

SLEEP=1
for((i=0;i<5;++i)); do
    bq insert android-devtools-lldb-build:LLDB_buildbots.build_stats <"rev-$rev.bq" && break

    # The above command seems to occasionally fail with the error:
    # BigQuery error in insert operation: Error encountered during execution. Retrying
    # may solve the problem.
    # So, let's retry...
    sleep $SLEEP
    SLEEP=$((2*SLEEP))
done

rm "rev-$rev.bq"
