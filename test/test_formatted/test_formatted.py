import subprocess
import os


def test_formatted():
    currentpath = os.path.dirname(os.path.abspath(__file__))
    os.chdir(currentpath)
    os.chdir("/../../")
    buildcommand = "make clean && FC=gfortran make"
    subprocess.run(buildcommand, shell=True)
    reference = "ref.out"
    output = "debug"
    os.chdir(currentpath)
    command = "../../readmdcint"
    subprocess.run(command, shell=True)
    # Compare the output with the reference (all lines must be identical)
    with open(reference, "r") as ref, open(output, "r") as out:
        for ref_line, out_line in zip(ref, out):
            assert ref_line == out_line
