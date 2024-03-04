#!/usr/bin/env python

from setuptools import setup

setup(
    name="jax-test",
    version="1.0",
    # Modules to import from other scripts:
    # packages=find_packages(),
    # Executables
    # scripts=["Acquisition.py"],
    entry_points={"console_scripts": ["jax-test = jax_test:main"]},
)
