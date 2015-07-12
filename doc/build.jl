using Expresso, Expresso.Templates

build("Expresso.jl") do

file"""
../README.md

# Expresso

[![Build Status](https://travis-ci.org/MichaelHatherly/Expresso.jl.svg?branch=master)](https://travis-ci.org/MichaelHatherly/Expresso.jl)

Expression and macro utilities for Julia.

## Installation

``Expresso.jl`` is an unregistered package and can be installed with ``Pkg.clone``:

    julia> Pkg.clone("https://github.com/MichaelHatherly/Expresso.jl")

## Description

{{Expresso}}

## Status

Currently a work-in-progress.

"""

file"""
reference.md

# Package Reference

#### ``@!``

{{@!}}

---

#### ``@merge``

{{@merge}}

---

#### ``@\\``

{{@\\}}

---

#### ``@S_str``

{{@S_str}}

---

#### ``Head``

{{Head}}

---

#### ``@H_str``

{{@H_str}}

---

#### ``@defmacro``

{{@defmacro}}

---

#### ``@for``

{{@for}}

"""

end
