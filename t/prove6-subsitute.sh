#!/bin/bash

for f in t/*t; do raku -I. $f; done

