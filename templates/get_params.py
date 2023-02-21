#!/usr/bin/env python
import pathlib
import re
# get raw path from nextflow
raw = pathlib.Path('${raw}')
# grab the first one, shouldn't be more lying around
samplesheet = list(raw.glob('CTG_*.csv'))[0]  

# first open file
with open(samplesheet, 'r') as f:
    # read the samplesheet into string
    ss = f.read()

# use regex to capture [BCLConvert_Data]()[*]
pattern = re.compile(r'.*BCLConvert_Data\]\n(.*?)\n\[', re.DOTALL)
data = pattern.findall(ss)[0]   

# find the Sample_Project column and extract unique values
my_split = data.split('\n')

# search in the first item
for i, item in enumerate(my_split[0].split(',')):
    if item == 'Sample_Project':
        # get the index of the column
        col = i

# make set with unique values in the column
projectids = set([item.split(',')[col] for item in my_split[1:]])

# write to file
with open('projectids.txt', 'w') as f:
    f.write('\n'.join(projectids))

# find the flowcell
# the flowcell is printed by the sequencer
# to RunParameters.xml
with open(raw / 'RunParameters.xml', 'r') as f:
    rp = f.read()

# use regex to capture <FlowcellSerialBarcode>(.*)</FlowCellSerialBarcode>
pattern = re.compile(r'.*<FlowCellSerialBarcode>(.*)</FlowCellSerialBarcode>.*', re.DOTALL)
flowcell = pattern.findall(rp)[0]

# write to file
with open('flowcell.txt', 'w') as f:
    f.write(flowcell)

# find the pipeline to run
# look for the pipeline name in the samplesheet
# under [Yggdrasil_Settings]
pattern = re.compile(r'.*Yggdrasil_Settings\]\n.*Pipeline,(\w),.*', re.DOTALL)
pipeline = pattern.findall(ss)[0]

# write to file
with open('pipeline.txt', 'w') as f:
    f.write(pipeline)

# also write out the content of samplesheet
with open('SampleSheet.csv', 'w') as f:
    f.write(ss)