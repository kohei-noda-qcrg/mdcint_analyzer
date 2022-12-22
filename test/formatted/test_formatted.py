import subprocess
import os


def test_formatted():
    currentpath = os.path.dirname(os.path.abspath(__file__))
    os.chdir(currentpath)
    # rm formatted_MDCINT if it exists
    if os.path.exists("formatted_MDCINT"):
        os.remove("formatted_MDCINT")
    buildcommand = "make clean -C ../../ && FC=gfortran make -C ../../"
    subprocess.run(buildcommand, shell=True)
    reference = "ref.out"
    output = "formatted_MDCINT"
    command = "../../readmdcint -c"
    subprocess.run(command, shell=True)
    # Compare the output with the reference (all lines must be identical)
    with open(reference, "r") as ref, open(output, "r") as out:
        for ref_line, out_line in zip(ref, out):
            assert ref_line == out_line
