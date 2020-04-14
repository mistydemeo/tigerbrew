#!/usr/bin/python
import sys
import os
os.execv("/usr/bin/gcc", ["/usr/bin/gcc"] + [i for i in sys.argv[1:] if i != "-Wno-invalid-pp-token" and i != "-Wno-unicode"])
