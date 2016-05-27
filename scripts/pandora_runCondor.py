#!/usr/bin/python

import os, sys, getopt, re, subprocess

#-------------------------------------------------------------------------------------------------------------------------------------------
# && (Name == strcat("slot1@", Machine) || Name == strcat("slot3@", Machine) || Name == strcat("slot5@", Machine)) \n'

def GetJobString():
    jobString  = 'executable              = ' + os.getcwd() + '/scripts/pandora.sh                \n'
    jobString += 'initial_dir             = ' + os.getcwd()  +                 '                  \n'
    jobString += 'notification            = never                                                 \n'
    jobString += 'requirements            = (OSTYPE == \"SLC6\") && (LoadAvg < 0.5)               \n'
    jobString += 'request_memory          = 1024                                                  \n'
    jobString += 'rank                    = memory                                                \n'
    jobString += 'output                  = ' + os.getcwd() + '/log/larreco.out \n'
    jobString += 'error                   = ' + os.getcwd() + '/log/larreco.err \n'
    jobString += 'log                     = ' + os.getcwd() + '/log/larreco.log \n'
    jobString += 'environment             = CONDOR_JOB=true                                       \n'
    jobString += 'universe                = vanilla                                               \n'
    jobString += 'getenv                  = false                                                 \n'
    jobString += 'copy_to_spool           = true                                                  \n'
    jobString += 'should_transfer_files   = yes                                                   \n'
    jobString += 'when_to_transfer_output = on_exit_or_evict                                      \n'
    return jobString

#-------------------------------------------------------------------------------------------------------------------------------------------

def GetJobArguments(scripts, firstLine):
    arguments = firstLine.split()

    if 3 != len(arguments):
        print 'Invalid arguments found in runlist.'
        sys.exit(3)

    jobArguments = 'arguments = ' + firstLine + '\n'

    return jobArguments

#-------------------------------------------------------------------------------------------------------------------------------------------

def main():
    scripts = ''
    runlist = ''
    maxRuns = 110

    try:
        opts, args = getopt.getopt(sys.argv[1:],"r:m:",["scripts=","runlist=","maxRuns="])
    except getopt.GetoptError:
        print 'pandora_runCondor.py -r <runlist> -m <maxRuns>'
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print 'pandora_runCondor.py -r <runlist> -m <maxRuns>'
            sys.exit()
        elif opt in ("-r", "--runlist"):
            runlist = arg
        elif opt in ("-m", "--maxRuns"):
            maxRuns = arg
    
        maxRuns = int(maxRuns)

    if not runlist or not os.path.isfile(runlist):
        print 'Invalid runlist specified'
        sys.exit(2)

    while True:
        queueProcess = subprocess.Popen(['condor_q'], stdout=subprocess.PIPE)
        queueOutput = queueProcess.communicate()[0]

        regex = re.compile('pandora')
        queueList = regex.findall(queueOutput)
        nQueued = len(queueList)

        FNULL = open(os.devnull, 'w')

        if nQueued >= maxRuns:
            subprocess.call(["usleep", "500000"])
        else:
            with open(runlist, 'r') as file:
                firstLine = file.readline()
                fileContents = file.read().splitlines(True)

            nRemaining = len(fileContents)

            with open(runlist, 'w') as file:
                file.truncate()
                file.writelines(fileContents)

            with open('tempLArReco.job', 'w') as jobFile:
                jobFile.truncate()
                jobString  = GetJobString()
                jobString += GetJobArguments(scripts, firstLine)
                jobString += 'queue 1 \n'
                jobFile.write(jobString)

            subprocess.call(['condor_submit', 'tempLArReco.job'], stdout=FNULL, stderr=subprocess.STDOUT)
            sys.stdout.write('\r\033[K > Jobs queued: ' + str(nQueued) + '. Jobs still to submit: ' + str(nRemaining))
            sys.stdout.flush()
            subprocess.call(["usleep", "500000"])
            os.remove('tempLArReco.job')

        if 0 == nRemaining:
            print ''
            sys.exit(0)

#-------------------------------------------------------------------------------------------------------------------------------------------

if __name__ == "__main__":
    main()
