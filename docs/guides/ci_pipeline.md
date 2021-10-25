# Develop a CI Pipeline

In this exercise you will learn how to develop a CI pipeline that executes linting, testing, and building using GitHub actions.

## Prerequisites

To develop this exercise you should have done the [setup steps in the README.md](../../README.md)

## Exercise

### Setting up GitHub actions

1. First you need to create the following folder structure under your root directory: `.github/workflows/pipeline.yml`. This is the file that GitHub actions is going to use to execute our pipeline.

2. Then you need to setup your `.github/workflows/pipeline.yml` file as follows:

   ```yaml
   name: DevOpsPipeline
   on: [push]
   ```

   This will give our pipeline the `DevOpsPipeline` name and will only execute if we make push to our repository independently of the branch we are on.

### Creating a linting step

Before creating our linting step lets open the `src/kedro_devops/cli.py` file. After you open the file, scroll down until you find the `lint` function which looks something like this:

```python
@cli.command()
def lint() -> None:
    """
    Linting function that makes static code analysis for the project
    when executing "kedro lint"
    """
    separator = "-" * 20

    print(f"{separator}\nRunning Black...\n{separator}")
    python_call("black", ["."])

    print(f"{separator}\nRunning isort...\n{separator}")
    python_call("isort", ["src/kedro_devops", "src/tests"])

    print(f"{separator}\nRunning flake8...\n{separator}")
    python_call("flake8", ["src/kedro_devops"])

    print(f"{separator}\nRunning pydocstyle...\n{separator}")
    python_call(
        "pydocstyle",
        ["src/kedro_devops/pipelines"],
    )

    print(f"{separator}\nRunning mypy...\n{separator}")
    python_call(
        "mypy",
        ["src/kedro_devops/pipelines", "src/tests"],
    )
```

This function creates a new Kedro cli command under the `kedro lint` name, which execute different [linters](<https://en.wikipedia.org/wiki/Lint_(software)>) that validate statically that our code is up to good practices and standards previously defined by the team. Take your time to investigate each of the linter tools in order to fully understand what they do.

- [black](https://pypi.org/project/black/)
- [isort](https://pypi.org/project/isort/)
- [flake8](https://pypi.org/project/flake8/)
- [pydocstyle](https://pypi.org/project/pydocstyle/)
- [mypy](https://pypi.org/project/mypy/)

Now we will implement this command in our pipeline to validate that our code is compliant with good practices.

1. Go to pipeline configuration file `.github/workflows/pipeline.yml` and under your previous declaration add the following:
   ```yaml
    name: DevOpsPipeline
    on: [push]
    jobs:
        lint-project:
            runs-on: ubuntu-latest
            steps:
            - uses: actions/checkout@v2
            - uses: s-weigand/setup-conda@v1
                with:
                python-version: 3.7.9
            - name: Install kedro
                run: pip install kedro==0.17.5
            - name: Install dependencies
                run: |
                kedro build-reqs
                pip install -r src/requirements.txt
            - name: Run linting
                run: kedro lint
   ```
   Lets analyze every line of our configuration
   - **jobs:** as its name suggests, under this clause we are going to list all the jobs that our pipeline is intended to do
   - **lint-project:** is the name of the job that is responsible for linting our code
   - **runs-on:** this clause specifies the type of machine in which our job is going to run. GitHub actions offer different OS such as Ubuntu, Windows and MacOS
   - **steps:** under this clause we define all the steps that our job is supposed to do
