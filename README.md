<!-- badges: start -->
[![codecov](https://codecov.io/gh/dataupsurge/configulaR/graph/badge.svg?token=jCVVBVqP6a)](https://app.codecov.io/gh/dataupsurge/configulaR)
[![R-CMD-check](https://github.com/dataupsurge/configulaR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dataupsurge/configulaR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# configulaR

> Strict separation of settings from code.

*configulaR* is a port of the excellent [python-decouple](https://github.com/HBNetwork/python-decouple) library for R.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [How It Works](#how-it-works)
  - [Priority Rules](#priority-rules)
  - [Config File Search](#config-file-search)
- [Usage](#usage)
  - [On-the-fly Parameter Evaluation](#on-the-fly-parameter-evaluation)
  - [Preloading Config Files](#preloading-config-files)
  - [Handling Undefined Parameters](#undefined-parameters)
  - [Type Casting](#casting-argument)
- [Configuration File Formats](#implementated-parsers)
  - [INI Files](#ini-file)
  - [ENV Files](#env-file)

## Overview

As stated by its original author, *configulaR* makes it easy to:

- Store configuration parameters in *ini* or *.env* files
- Define comprehensive default values
- Properly convert values to the correct data type
- Have **only one** configuration module to rule all your application instances

configulaR's behavior mimics python-decouple as closely as possible and is tested against python-decouple's unit tests.

## Installation

```r
# Install from CRAN
install.packages("configulaR")

# Or install the development version from GitHub
# install.packages("devtools")
devtools::install_github("dataupsurge/configulaR")
```

## How It Works

### Priority Rules

*configulaR* always searches for configuration values in this order:

1. Environment variables
2. Repository config files: `.ini` or `.env` files
3. Default argument passed to `config`

Environment variables have precedence over config files to maintain Unix consistency.

### Config File Search

By default, config files are searched for in:
1. The current working directory
2. Any other directory provided via the `path` argument
3. Parent directories (if no config files are found in the current directory)

configulaR looks for either `settings.ini` or `.env` files.

## Usage

### On-the-fly Parameter Evaluation

Parameter values can be retrieved anytime by invoking the `configulaR::get_var` function:

```r
library(configulaR)

# Retrieve a value from environment or config file
api_key <- get_var('API_KEY', default='my-default-key')

# With type casting
debug_mode <- get_var('DEBUG', default=FALSE, cast='logical')
port_number <- get_var('PORT', default=3000, cast='integer')
```

If the `config` parameter is not provided, a config file search will be performed at each function call.

### Preloading Config Files

To avoid repeated config file searches, preload the configuration once:

```r
# Load config once
config <- get_config()

# Then use it for all subsequent calls
api_key <- get_var('API_KEY', config=config, default='my-default-key')
debug_mode <- get_var('DEBUG', config=config, default=FALSE, cast='logical')
```

### Undefined Parameters

If a parameter has no default value and doesn't exist in the environment or config files, *configulaR* will raise an error:

```r
# This will fail if SECRET_KEY is not defined anywhere
secret_key <- get_var('SECRET_KEY')

# This will use the default if SECRET_KEY is not defined
secret_key <- get_var('SECRET_KEY', default='fallback-secret-key')
```

This *fail-fast* policy helps you avoid subtle bugs when parameters are missing.

### Casting Argument

By default, all values returned by `configulaR` are `strings`.

To specify a different return type, use the `cast` argument:

```r
# Return as integer
max_connections <- get_var('MAX_CONNECTIONS', default='10', cast='integer')

# Return as logical
debug_enabled <- get_var('DEBUG', default='True', cast='logical')

# Return as float
timeout_seconds <- get_var('TIMEOUT', default='5.5', cast='float')

# Custom casting function
get_var('NUMBERS', default='1,2,3', cast=function(x) as.numeric(strsplit(x, ',')[[1]]))
```

Predefined casting types include:

- Integer: `'int'`, `'integer'`
- Boolean: `'bool'`, `'boolean'`, `'logical'`
- Float: `'float'`

## Implementated Parsers

*configulaR* supports both `.ini` and `.env` files.

### Ini File

configulaR can read *ini* files and provide simple interpolation.

Simply create a `settings.ini` in your working directory or in its parent directories:

```ini
[settings]
DEBUG=True
TEMPLATE_DEBUG=%(DEBUG)s
SECRET_KEY=ARANDOMSECRETKEY
DATABASE_URL=mysql://myuser:mypassword@myhost/mydatabase
PERCENTILE=90%%
#COMMENTED=42
```

### Env File

Create a `.env` text file in your repository's root directory:

```bash
DEBUG=True
TEMPLATE_DEBUG=True
SECRET_KEY=ARANDOMSECRETKEY
DATABASE_URL=mysql://myuser:mypassword@myhost/mydatabase
PERCENTILE=90%
#COMMENTED=42
```
