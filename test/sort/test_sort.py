import subprocess
import os
import pytest

params = [
    ("-t 1", "ref.type1.out", "type1.out"),
    ("-t 2 -r -10 10", "ref.type2.range_-10_10.out", "type2.out"),
]


@pytest.mark.parametrize("commandargs, expected, actual", params)
def test_formatted(commandargs, expected, actual):
    currentpath = os.path.dirname(os.path.abspath(__file__))
    os.chdir(currentpath)
    command = "../../sort_mdcint {} > {}".format(commandargs, actual)
    subprocess.run(command, shell=True)
    # Compare the output with the reference (all lines must be identical)
    with open(expected, "r") as ref, open(actual, "r") as out:
        for ref_line, out_line in zip(ref, out):
            assert ref_line == out_line
