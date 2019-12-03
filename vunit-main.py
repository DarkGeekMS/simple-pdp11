from os.path import join, dirname
from vunit import VUnit

vu = VUnit.from_argv()
vu.add_osvvm()
vu.add_verification_components()

src_path = join(dirname(__file__), "src")
test_path = join(dirname(__file__), "test")

vu.add_library("pdp11").add_source_files(
    [join(src_path, "*.vhd*"), join(test_path, "*.vhd*")]
)
# TODO: add compile options
vu.main()
