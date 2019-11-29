#!/bin/bash

folder=$1
fileExtension=$2
encode=$3

number=$4

echo "${folder}*.${fileExtension}"




find $folder -name "*.${fileExtension}" -maxdepth 1 -type f |while read myFile; do

  f=$myFile
  # strip extension
  filenamestub="${f##*/}"
  filename="${filenamestub%.*}.mp3"
  echo filename $filename
  ffmpeg -y -i $myFile -acodec libmp3lame -ab $3 "$folder/$filename"
  oldFile=$filename
  echo oldFile $oldFile $filenamestub
  outputFolder="${folder}/${filenamestub%.*}"
  mkdir $outputFolder
  echo $outputFolder
  for ((i = 0 ; i <= $number ; i++));
  do
     newFile="${filenamestub%.*}_${i}.mp3"
     ffmpeg -loglevel panic -y -i "$folder/$oldFile" -acodec libmp3lame -ab $3 "$folder/$newFile"
     mv "$folder/$oldFile" "$outputFolder"
     oldFile=$newFile
  done

 echo "completed 75 exports at ${3}"
 newOut="${filenamestub%.*}_output.wav"
 ffmpeg  -y -i "$folder/$oldFile" "$folder/$newOut"
 newWav="${filenamestub%.*}_output_phase.wav"
 #ffmpeg  -y -i "$folder/$newOut" -af pan="stereo:c0=c0:c1=-1*c1" -ac 1 "$folder/$newWav"
 ffmpeg  -y -i "$folder/$newOut" -af "aeval='-val(0):c=same'" "$folder/$newWav"
 mv "$folder/$oldFile" "$outputFolder"

 inOrig="${filenamestub%.*}_input.wav"
 ffmpeg  -y -i "$myFile" "$folder/$inOrig"

invWav="${filenamestub%.*}_input_phase.wav"
ffmpeg  -y -i "$myFile" -af "aeval='-val(0)':c=same" "$folder/$invWav"
 newMix="${filenamestub%.*}_output_cancelled.wav"
 ffmpeg -i "$folder/$inOrig" -i "$folder/$newWav" -filter_complex "[0:a][1:a]amerge=inputs=2[aout]" -map "[aout]" -ac 2 "$folder/$newMix"

 newInputMix="${filenamestub%.*}_input_cancelled.wav"
 ffmpeg -i "$folder/$inOrig" -i "$folder/$invWav" -filter_complex "[0:a][1:a]amerge=inputs=2[aout]" -map "[aout]" -ac 2 "$folder/$newInputMix"


echo move phase
   mv "$folder/$newOut" "$outputFolder"
   mv "$folder/$newWav" "$outputFolder"
   mv "$folder/$newMix" "$outputFolder"
   mv "$folder/$invWav" "$outputFolder"
   mv "$folder/$newInputMix" "$outputFolder"
   mv "$folder/$inOrig" "$outputFolder"




done;

