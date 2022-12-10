import subprocess
import os
import pytest

params = [
    ("-i A.out B.out --diff", "ref.diff.out", "diff.out"),
    ("-i A.out B.out --ins", "ref.ins.out", "ins.out"),
    ("-i A.out B.out --uni", "ref.uni.out", "uni.out"),
    ("-i A.out B.out --sdiff", "ref.sdiff.out", "sdiff.out"),
]


@pytest.mark.parametrize("commandargs, expected, actual", params)
def test_get_diff(commandargs, expected, actual):
    currentpath = os.path.dirname(os.path.abspath(__file__))
    os.chdir(currentpath)
    command = "../../get_diff_mdcint {} > {}".format(commandargs, actual)
    subprocess.run(command, shell=True)
    # Compare the output with the reference (all lines must be identical)
    with open(expected, "r") as ref, open(actual, "r") as out:
        for ref_line, out_line in zip(ref, out):
            assert ref_line == out_line
