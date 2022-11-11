#!/bin/sh


tests="test_20_snrs test_15_snrs test_10_snrs test_5_snrs"
for test in $tests;do
  i=0
  IFS=$'\n'
  mv data/$test/wav.scp data/$test/wav.scp.cmd
  for line in `cat data/$test/wav.scp.cmd`;do
    i=$((${i} + 1))
    uttid=`echo $line | cut -d" " -f1`
    wav=`echo $line | cut -d" " -f 2-8` 
    out_wav=$PWD/data/$test/wav
    if [ ! -d $out_wav ];then
         mkdir $out_wav
    fi
    out_wav_file=$out_wav/$uttid".wav"
    wav_command=$wav" "${out_wav_file}
    #echo ${wav_command}
    eval ${wav_command}
    echo $uttid" "${out_wav_file} >> $PWD/data/$test/wav.scp
    echo $i
done 
done

