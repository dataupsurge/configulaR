set dotenv-load

python_version := `cat .python-version`
project_venv := '.venv'
python := project_venv + '/bin/python'
pip := project_venv + '/bin/pip'
pre_commit := project_venv + '/bin/pre-commit'

# Default to just --list
default:
	@just --list

# Clean the environment
clean-all:
	rm -rf renv || true
	rm -rf {{project_venv}} || true
	rm -rf src/vendor || true
	sed -i '/source("renv\/activate.R")/d' .Rprofile || true

# Set-up dev environment
init-dev: clean-all init-precommit init-renv
	R -e 'renv::restore()'

init-ci: init-renv
	R -e 'renv::restore()'

# Set-up renv
init-renv:
	rm -rf renv || true
	sed -i '/source("renv\/activate.R")/d' .Rprofile || true
	R -e 'renv::consent(provided = TRUE)'
	R -e 'renv::init(bare=TRUE)'

# Set-up pre-commit
init-precommit:
	rm -rf {{project_venv}} || true
	python -m venv {{project_venv}} 
	{{pip}} install pre-commit
	{{pre_commit}} install --install-hooks -t prepare-commit-msg -t pre-push -t commit-msg

# Install dev dependencies
install-dev-deps:
	R -e 'renv::install()'

# Should be only use to generate the first version of renv.lock
gen-renv-dev-lock: clean-all init-precommit init-renv install-dev-deps freeze

# Update dependencies
depts-update:
	R -e 'renv::update()'

# renv snapshot
freeze:
	R -e 'renv::snapshot(type="all")'

# Check package
check-pkg:
	R -e 'devtools::check()'

# Update pre-commit
update-pre-commit:
	{{pre_commit}} autoupdate

# Run pre-commit to all files
pre-commit:
	{{pre_commit}} run --all-files

# Lint code
lint: ## Perform code sanity checks if needed
	R -e 'lintr::lint_package()'

# Performs sanity check on code
sanity-check: ## Perform code sanity checks if needed
	R -e "goodpractice::gp()"
	R -e 'devtools::spell_check()'

# Run test suite
test:
	R -e 'devtools::test()'

# Run test with coverage
test-cov:
	cp -f .env .Renviron
	R -e 'covr::package_coverage()'

# Generate documentation
document:
	R -e 'devtools::document()'

# Style code
style:
	R -e 'styler::style_pkg()'

# Build the package source
build: document
	R -e 'devtools::build()'

# Build the packdown site
build-pkgdown:
	R -e 'pkgdown::build_site()'
