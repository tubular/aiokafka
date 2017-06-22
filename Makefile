# Some simple testing tasks (sorry, UNIX only).

FLAGS=
SCALA_VERSION?=2.11
KAFKA_VERSION?=0.10.1.0
DOCKER_IMAGE=aiolibs/kafka:$(SCALA_VERSION)_$(KAFKA_VERSION)
DIFF_BRANCH=origin/master
APP_PATH := $(shell pwd)
VENV_PATH := $(APP_PATH)/venv_aiokafka
PIP_PATH := $(VENV_PATH)/bin/pip

venv:	 $(VENV_PATH)/reqs_installed

$(VENV_PATH)/reqs_installed: $(VENV_PATH)
	$(PIP_PATH) install --upgrade pip
	$(PIP_PATH) install --upgrade 'setuptools>=0.8'
	$(PIP_PATH) install wheel
	touch $(VENV_PATH)/reqs_installed

$(VENV_PATH):
	pip install virtualenv
	virtualenv -p $(shell which python3) -q $(VENV_PATH)

setup:
	pip install -r requirements-dev.txt
	pip install -Ue .

dist:	 $(VENV_PATH)/reqs_installed
	 python3.5 setup.py bdist_wheel

flake:
	extra=$$(python -c "import sys;sys.stdout.write('--exclude tests/test_pep492.py') if sys.version_info[:3] < (3, 5, 0) else sys.stdout.write('')"); \
	flake8 aiokafka tests $$extra

test: flake
	py.test -s --no-print-logs --docker-image $(DOCKER_IMAGE) $(FLAGS) tests

vtest: flake
	py.test -s -v --no-print-logs --docker-image $(DOCKER_IMAGE) $(FLAGS) tests

cov cover coverage: flake
	py.test -s --no-print-logs --cov aiokafka --cov-report html --docker-image $(DOCKER_IMAGE) $(FLAGS) tests
	@echo "open file://`pwd`/htmlcov/index.html"

coverage.xml: .coverage
	coverage xml

diff-cov: coverage.xml
	git fetch
	diff-cover coverage.xml --html-report diff-cover.html --compare-branch=$(DIFF_BRANCH)

clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -f `find . -type f -name '@*' `
	rm -f `find . -type f -name '#*#' `
	rm -f `find . -type f -name '*.orig' `
	rm -f `find . -type f -name '*.rej' `
	rm -f .coverage
	rm -rf htmlcov
	rm -rf docs/_build/
	rm -rf cover
	rm -rf dist

doc:
	make -C docs html
	@echo "open file://`pwd`/docs/_build/html/index.html"

.PHONY: all flake test vtest cov clean doc
