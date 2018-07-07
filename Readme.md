# ConcreteInterfaces.jl

[![Build Status](https://travis-ci.org/rdeits/ConcreteInterfaces.jl.svg?branch=master)](https://travis-ci.org/rdeits/ConcreteInterfaces.jl) [![codecov.io](http://codecov.io/github/rdeits/ConcreteInterfaces.jl/coverage.svg?branch=master)](http://codecov.io/github/rdeits/ConcreteInterfaces.jl?branch=master)

Check out [demo.ipynb](demo.ipynb) for some examples of usage.

# How it Works

An interface is just a struct containing one or more [FunctionWrappers](https://github.com/yuyichao/FunctionWrappers.jl). The `@interface` macro makes it easier to define and consume interfaces.

Note: this project uses a modified copy of [ComputedFieldTypes.jl](https://github.com/vtjnash/ComputedFieldTypes.jl). See `src/ComputedFieldTypes/LICENSE` for attribution and license information for that code.

