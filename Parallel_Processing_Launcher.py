#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:     Launching parallel processes for each of the codes involved in the
#              rooftop suitability analysis
#
# Author:      Carlos Javier Delgado
#              Subprocess structure from UPRA github
# Created:     22/10/2019
# Copyright:
# Licence:
#-------------------------------------------------------------------------------

import os
import sys
import subprocess
import time
import datetime

def main():

    print("Launching parallel process...")
    initial_t = time.clock()
    print(datetime.datetime.now())

    #Getting path of python shell application
    pydir = sys.exec_prefix
    pyexe = os.path.join(pydir, "python.exe")
    print(pyexe)

    #Defining number of parallel process
    num_parallel_processes = 5

    #Defining the python files that will be executed hen using parallel processing
    script_1 = r"D:\Geo_Tech_Master\Thesis_Research\Code\Initial_Rooftop_Statistics_Calculation.py"
    script_1 = r"D:\Geo_Tech_Master\Thesis_Research\Code\Rooftop_Flatness_Elongation_Assessment.py"
    chain_subprocess = ""
    chain_wait = ""

    aCommands = []
    for i in range(num_parallel_processes):
        aCommands.append(r"start python %s %s"%(script_1, i+1))

    print(aCommands)

    #Defining the chain of parameters necessary for subprocess execution
    for j in range(num_parallel_processes):

        if j+1 < num_parallel_processes:
            chain_subprocess += "%s = subprocess.Popen(aCommands[%s], stdin=None,stdout=subprocess.PIPE,shell=True);"%("ch"+str(j+1), j)
            chain_wait += "astdout, astderr = %s.communicate();"%("ch"+str(j+1))
        else:
            chain_subprocess += "%s = subprocess.Popen(aCommands[%s], stdin=None,stdout=subprocess.PIPE,shell=True)"%("ch"+str(j+1), j)
            chain_wait += "astdout, astderr = %s.communicate()"%("ch"+str(j+1))

    print(chain_subprocess)
    print(chain_wait)

    chain_subprocess = compile(chain_subprocess, '<string>', 'exec')
    exec(chain_subprocess)
    chain_wait = compile(chain_wait, '<string>', 'exec')
    exec(chain_wait)


    print("Ending parallel processing...")
    print(datetime.datetime.now())
    print("Parallel process executed in " + str(((time.clock() - initial_t))/60))

if __name__ == '__main__':
    main()

